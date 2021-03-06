require "test_helper"

describe WorksController do
  let(:existing_work) { Work.first }
  let (:user) { User.first }
  let (:user2) { User.find_by(id: existing_work.user_id) }

  CATEGORIES = %w(albums books movies)
  INVALID_CATEGORIES = ["nope", "42", "", "  ", "albumstrailingtext"]

  describe 'guest user' do
    it 'can access root path' do
      get root_path
      must_respond_with :success
    end

    it 'cannot access index' do
      get works_path
      must_redirect_to root_path
      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal 'You must log in to do that'
    end

    it 'cannot access show' do
      get works_path(existing_work.id)
      must_redirect_to root_path
      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal 'You must log in to do that'
    end

    it 'cannot access new work form' do
      get new_work_path
      must_redirect_to root_path
      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal 'You must log in to do that'
    end

    it 'cannot access edit work form' do
      get new_work_path
      must_redirect_to root_path
      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal 'You must log in to do that'
    end

    it 'cannot update work' do
      updates = { work: { title: "Dirty Computer" } }

      expect {
        put work_path(existing_work), params: updates
      }.wont_change "Work.count"

      must_redirect_to root_path
      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal 'You must log in to do that'
    end

    it 'cannot destroy work' do
      expect {
        delete work_path(existing_work.id)
      }.wont_change "Work.count"

      must_redirect_to root_path
      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal 'You must log in to do that'
    end

    it 'cannot upvote: redirects to the work page if no user is logged in' do
      post upvote_path(existing_work.id)

      must_respond_with :redirect
      expect(flash[:result_text]).must_equal 'You must log in to do that'
    end
  end

  describe 'logged in user' do
    before do
      perform_login(user)
    end

    describe "index" do
      it "succeeds when there are works" do
        get works_path
        must_respond_with :success
      end

      it "succeeds when there are no works" do
        Work.all(&:destroy)
        get works_path
        must_respond_with :success
      end
    end

    describe "new" do
      it "succeeds" do
        get new_work_path
        must_respond_with :success
      end
    end

    describe "show" do
      it "succeeds for an extant work ID" do
        get work_path(existing_work.id)
        must_respond_with :success
      end

      it "renders 404 not_found for a bogus work ID" do
        destroyed_id = existing_work.id
        existing_work.destroy

        get work_path(destroyed_id)

        must_respond_with :not_found
      end
    end

    describe "edit" do
      it "succeeds for an extant work ID given the correct logged-in user" do
        existing_work
        perform_login(user2)

        get edit_work_path(existing_work.id)

        must_respond_with :success
      end

      it "fails for an extant work ID given incorrect logged-in user" do
        get edit_work_path(existing_work.id)

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal 'You must have created this work to edit or delete it.'
      end

      it "renders 404 not_found for a bogus work ID" do
        bogus_id = existing_work.id
        existing_work.destroy

        get edit_work_path(bogus_id)

        must_respond_with :not_found
      end
    end

    describe "update" do
      it "succeeds for valid data and an extant work ID given logged-in creator-user" do
        perform_login(user2)
        updates = { work: { title: "Dirty Computer" } }

        expect {
          put work_path(existing_work), params: updates
        }.wont_change "Work.count"
        updated_work = Work.find_by(id: existing_work.id)

        expect(updated_work.title).must_equal "Dirty Computer"
        must_respond_with :redirect
        must_redirect_to work_path(existing_work.id)
      end

      it "fails for valid data and an extant work ID if not logged-in creator-user" do
        updates = { work: { title: "Dirty Computer" } }

        expect {
          put work_path(existing_work), params: updates
        }.wont_change "Work.count"

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal 'You must have created this work to edit or delete it.'
      end

      it "renders bad_request for bogus data given logged in creator-user" do
        perform_login(user2)
        updates = { work: { title: nil } }

        expect {
          put work_path(existing_work), params: updates
        }.wont_change "Work.count"

        work = Work.find_by(id: existing_work.id)

        must_respond_with :not_found
      end

      it "renders 404 not_found for a bogus work ID given logged in creator-user" do
        perform_login(user2)
        bogus_id = existing_work.id
        existing_work.destroy

        put work_path(bogus_id), params: { work: { title: "Test Title" } }

        must_respond_with :not_found
      end
    end

    describe "destroy" do
      it "succeeds for an extant work ID if given the correct user" do
        perform_login(user2)

        expect {
          delete work_path(existing_work.id)
        }.must_change "Work.count", -1

        must_respond_with :redirect
        must_redirect_to root_path
      end

      it "fails for an extant work ID if given incorrect user" do
        expect {
          delete work_path(existing_work.id)
        }.wont_change "Work.count"

        must_respond_with :redirect
        must_redirect_to root_path
        expect(flash[:status]).must_equal :failure
        expect(flash[:result_text]).must_equal 'You must have created this work to edit or delete it.'
      end

      it "renders 404 not_found and does not update the DB for a bogus work ID" do
        bogus_id = existing_work.id
        existing_work.destroy

        expect {
          delete work_path(bogus_id)
        }.wont_change "Work.count"

        must_respond_with :not_found
      end
    end

    describe "upvote" do
      it "redirects to the work page after the user has logged out" do
        expect(session[:user_id]).must_equal user.id

        delete logout_path
        assert_nil(session[:user_id])

        post upvote_path(existing_work.id)

        must_respond_with :redirect
        expect(flash[:result_text]).must_equal 'You must log in to do that'
      end

      it "succeeds for a logged-in user and a fresh user-vote pair" do
        user_vote_ct = user.votes.count
        work_vote_ct = existing_work.votes.count

        # perform_login(user)
        expect(session[:user_id]).must_equal user.id

        expect { post upvote_path(existing_work.id) }.must_change 'Vote.count', 1
        expect(user.votes.count).must_equal user_vote_ct + 1
        expect(existing_work.votes.count).must_equal work_vote_ct + 1
        expect(flash[:status]).must_equal :success
        expect(flash[:result_text]).must_equal 'Successfully upvoted!'
      end

      it "redirects to the work page if the user has already voted for that work" do
        expect(session[:user_id]).must_equal user.id

        post upvote_path(existing_work.id)

        user_vote_ct = user.votes.count
        work_vote_ct = existing_work.votes.count

        expect { post upvote_path(existing_work.id) }.wont_change 'Vote.count'
        expect(user.votes.count).must_equal user_vote_ct
        expect(existing_work.votes.count).must_equal work_vote_ct
        expect(flash[:result_text]).must_equal 'Could not upvote'
      end
    end

    describe "create" do
      it "creates a work with valid data for a real category" do
        new_work = { work: { title: "Dirty Computer", category: "album" } }

        expect {
          post works_path, params: new_work
        }.must_change "Work.count", 1

        new_work_id = Work.find_by(title: "Dirty Computer").id

        must_respond_with :redirect
        must_redirect_to work_path(new_work_id)
      end

      it "renders bad_request and does not update the DB for bogus data" do
        bad_work = { work: { title: nil, category: "book" } }

        expect {
          post works_path, params: bad_work
        }.wont_change "Work.count"

        must_respond_with :bad_request
      end

      it "renders 400 bad_request for bogus categories" do
        INVALID_CATEGORIES.each do |category|
          invalid_work = { work: { title: "Invalid Work", category: category } }

          expect { post works_path, params: invalid_work }.wont_change "Work.count"

          expect(Work.find_by(title: "Invalid Work", category: category)).must_be_nil
          must_respond_with :bad_request
        end
      end
    end
  end

  describe "root" do
    it "succeeds with all media types" do
      get root_path
      must_respond_with :success
    end

    it "succeeds with one media type absent" do
      Work.where(category: 'album').destroy_all
      get root_path
      must_respond_with :success
    end

    it "succeeds with no media" do
      Work.all(&:destroy)

      get root_path

      must_respond_with :success
    end
  end
end
