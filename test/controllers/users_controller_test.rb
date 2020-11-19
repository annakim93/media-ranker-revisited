require 'test_helper'

describe UsersController do

  let (:user) { User.first }

  describe 'login' do
    it 'logs in an existing user and redirects to the root route' do
      start_count = User.count
      perform_login(user)

      must_redirect_to root_path
      expect(session[:user_id]).must_equal user.id
      expect(User.count).must_equal start_count
    end

    it 'creates an account for a new user and redirects to the root route' do
      new_user = User.new(
        username: 'username',
        provider: 'github',
        email: 'someone@somewhere.com',
        uid: 123
      )

      expect{
        perform_login(new_user)
      }.must_change 'User.count', 1

      must_redirect_to root_path
      expect(session[:user_id]).must_equal User.last.id
    end

    it 'redirects to the login route if given invalid user data' do
      new_user = User.new(
        username: nil,
        provider: 'github',
        email: 'someone@somewhere.com',
        uid: 123
      )

      expect{
        perform_login(new_user)
      }.wont_change 'User.count'

      must_redirect_to root_path
      assert_nil(session[:user_id])

      user = User.find_by(uid: new_user.uid, provider: new_user.provider)
      assert_nil(user)
    end
  end

  describe 'logout' do
    it 'can logout an existing user' do
      perform_login(user)

      delete logout_path

      assert_nil(session[:user_id])
      must_redirect_to root_path
    end

    it 'cannot logout if not already logged in' do
      delete logout_path

      expect(flash[:status]).must_equal :failure
      expect(flash[:result_text]).must_equal 'You must log in to do that'
      must_redirect_to root_path
    end
  end
end
