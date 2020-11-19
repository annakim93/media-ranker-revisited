require "test_helper"

describe UsersController do

  let (:user) { User.first }

  describe 'login' do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count
      perform_login(user)

      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
      expect(User.count).must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
      new_user = User.new(
        username: 'username',
        provider: 'github',
        email: 'someone@somewhere.com',
        uid: 123
      )

      expect{
        perform_login(new_user)
      }.must_change "User.count", 1

      must_redirect_to root_path
      expect(session[:user_id]).must_equal User.last.id
    end

    it "redirects to the login route if given invalid user data" do
    end
  end

end
