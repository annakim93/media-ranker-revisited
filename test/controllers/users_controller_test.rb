require "test_helper"

describe UsersController do

  let (:user) { User.first }

  describe 'login' do
    it "logs in an existing user and redirects to the root route" do
      start_count = User.count
      OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(mock_auth_hash(user))

      get omniauth_callback_path(:github)
      must_redirect_to root_path

      expect(session[:user_id]).must_equal user.id

      expect(User.count).must_equal start_count
    end

    it "creates an account for a new user and redirects to the root route" do
    end

    it "redirects to the login route if given invalid user data" do
    end
  end

end
