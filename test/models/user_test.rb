require "test_helper"

describe User do
  let (:user) { User.first }

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
  end

  describe "validations" do
    it "requires a username" do
      user = User.new(uid: 123)
      expect(user.valid?).must_equal false
      expect(user.errors.messages).must_include :username
    end

    it "requires a unique username" do
      username = "test username"
      user1 = User.new(username: username, uid: 123)

      user1.save!

      user2 = User.new(username: username, uid: 456)
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
      user1 = User.new(username: 'test1', uid: uid)
      user1.save!

      user2 = User.new(username: 'test2', uid: 123)
      result = user2.save
      expect(result).must_equal false
      expect(user2.errors.messages).must_include :uid
    end
  end
end
