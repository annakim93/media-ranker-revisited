require "test_helper"

describe User do
  let (:user) { User.first }
  let (:auth_hash) {
    {
        provider: 'github',
        uid: 123456,
        info: {
            email: 'test@test.com',
            name: 'testtest'
        }
    }
  }

  describe "relations" do
    it "has a list of votes" do
      expect(user).must_respond_to :votes
      user.votes.each do |vote|
        expect(vote).must_be_kind_of Vote
      end
    end

    it "has a list of ranked works" do
      expect(user).must_respond_to :ranked_works
      user.ranked_works.each do |work|
        expect(work).must_be_kind_of Work
      end
    end

    it 'has works that were created by them' do
      expect(user).must_respond_to :works
      user.works.each do |work|
        expect(work).must_be_kind_of Work
      end
    end
  end

  describe "validations" do
    it "requires a username" do
      user = User.new(uid: 123)
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :username
    end

    it "requires a unique username" do
      username = "test username"
      user1 = User.new(username: username, uid: 123, email: 'test@test.com')

      user1.save!

      user2 = User.new(username: username, uid: 456, email: 'test2@test.com')
      result = user2.save
      expect(result).must_equal false
      expect(user2.errors.messages).must_include :username
    end

    it 'requires a uid' do
      user = User.new(username: 'test')
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :uid
    end

    it 'requires a unique uid' do
      uid = 123
      user1 = User.new(username: 'test1', uid: uid, email: 'test@test.com')
      user1.save!

      user2 = User.new(username: 'test2', uid: 123, email: 'test2@test.com')
      result = user2.save
      expect(result).must_equal false
      expect(user2.errors.messages).must_include :uid
    end

    it 'must have an email address' do
      user.email = nil
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :email
    end

    it 'must have a unique email address' do
      user.email = User.last.email

      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :email
      expect(user.errors.messages[:email]).must_equal ['has already been taken']
    end
  end

  describe 'custom methods' do
    it 'build_from_github: returns a user given a hash' do
      new_user = User.build_from_github(auth_hash)

      expect(new_user.username).must_equal auth_hash[:info][:name]
      expect(new_user.email).must_equal auth_hash[:info][:email]
      expect(new_user.uid).must_equal auth_hash[:uid]
      expect(new_user.provider).must_equal auth_hash[:provider]
    end
  end
end
