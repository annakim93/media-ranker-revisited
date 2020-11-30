require "test_helper"

describe Vote do
  let (:v) { Vote.first }

  describe "relations" do
    it "has a user" do
      expect(v).must_respond_to :user
      expect(v.user).must_be_kind_of User
    end

    it "has a work" do
      expect(v).must_respond_to :work
      expect(v.work).must_be_kind_of Work
    end
  end

  describe "validations" do
    before do
      @user1 = User.create!(username: "chris", uid: 123, email: 'chris@ada.com')
      @user2 = User.create!(username: "anna", uid: 321, email: 'anna@banana.com')
      @work1 = Work.create!(category: "book", title: "House of Leaves", user_id: @user1.id)
      @work2 = Work.create!(category: "book", title: "For Whom the Bell Tolls", user_id: @user2.id)
    end

    it "allows one user to vote for multiple works" do
      vote1 = Vote.new(user: @user1, work: @work1)
      vote1.save!
      vote2 = Vote.new(user: @user1, work: @work2)
      expect(vote2.valid?).must_equal true
    end

    it "allows multiple users to vote for a work" do
      vote1 = Vote.new(user: @user1, work: @work1)
      vote1.save!
      vote2 = Vote.new(user: @user2, work: @work1)
      expect(vote2.valid?).must_equal true
    end

    it "doesn't allow the same user to vote for the same work twice" do
      vote1 = Vote.new(user: @user1, work: @work1)
      vote1.save!
      vote2 = Vote.new(user: @user1, work: @work1)
      expect(vote2.valid?).must_equal false
      expect(vote2.errors.messages).must_include :user
    end
  end
end
