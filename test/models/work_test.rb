require 'test_helper'

describe Work do

  let (:work) {
    Work.first
  }

  describe 'relations' do
    it 'has many votes' do
      expect(work).must_respond_to :votes
      work.votes.each do |vote|
        expect(vote).must_be_kind_of Vote
      end
    end

    it 'has many voting users' do
      expect(work).must_respond_to :ranking_users
      work.ranking_users.each do |user|
        expect(work).must_be_kind_of User
      end
    end
    
    it 'belongs to a creator user' do
      expect(work).must_respond_to :user
      expect(work.user).must_be_kind_of User
    end
  end

  describe 'validations' do
    it 'allows the three valid categories' do
      valid_categories = ['album', 'book', 'movie']
      valid_categories.each do |category|
        work = Work.new(title: 'test', category: category, user_id: User.first.id)
        expect(work.valid?).must_equal true
      end
    end

    it 'fixes almost-valid categories' do
      categories = ['Album', 'albums', 'ALBUMS', 'books', 'mOvIeS']
      categories.each do |category|
        work = Work.new(title: 'test', category: category, user_id: User.first.id)
        expect(work.valid?).must_equal true
        expect(work.category).must_equal category.singularize.downcase
      end
    end

    it 'rejects invalid categories' do
      invalid_categories = ['cat', 'dog', 'phd thesis', 1337, nil]
      invalid_categories.each do |category|
        work = Work.new(title: 'test', category: category, user_id: User.first.id)
        expect(work.valid?).must_equal false
        expect(work.errors.messages).must_include :category
      end
    end

    it 'requires a title' do
      work = Work.new(category: 'ablum')
      expect(work.valid?).must_equal false
      expect(work.errors.messages).must_include :title
    end

    it 'requires unique names w/in categories' do
      category = 'album'
      title = 'test title'
      work1 = Work.new(title: title, category: category, user_id: User.first.id)
      work1.save!

      work2 = Work.new(title: title, category: category, user_id: User.first.id)
      expect(work2.valid?).must_equal false
      expect(work2.errors.messages).must_include :title
    end

    it 'does not require a unique name if the category is different' do
      title = 'test title'
      work1 = Work.new(title: title, category: 'album', user_id: User.first.id)
      work1.save!

      work2 = Work.new(title: title, category: 'book', user_id: User.first.id)
      expect(work2.valid?).must_equal true
    end
  end

  describe 'vote_count' do
    it 'defaults to 0' do
      work = Work.create!(title: 'test title', category: 'movie', user_id: User.first.id)
      expect(work).must_respond_to :vote_count
      expect(work.vote_count).must_equal 0
    end

    it 'tracks the number of votes' do
      4.times do |i|
        user = User.create!(username: "test_user_#{i}", uid: i, email: "test#{i}@test.com")
        Vote.create!(user: user, work: work)
      end
      expect(work.vote_count).must_equal 4
      expect(Work.find(work.id).vote_count).must_equal 4
    end
  end

  describe 'top_ten' do
    it 'returns a list of media of the correct category' do
      movies = Work.top_ten('movie')
      expect(movies.length).must_equal 4
      movies.each do |movie|
        expect(movie).must_be_kind_of Work
        expect(movie.category).must_equal 'movie'
      end
    end

    it 'orders media by vote count' do
      movies = Work.top_ten('movie')
      previous_vote_count = 100
      movies.each do |movie|
        expect(movie.vote_count).must_be :<=, previous_vote_count
        previous_vote_count = movie.vote_count
      end
    end

    it 'returns at most 10 items' do
      movies = Work.top_ten('movie')
      expect(movies.length).must_equal 4

      10.times do |num|
        Work.create(title: "test movie #{num}", category: 'movie', user_id: User.first.id)
      end

      expect(Work.top_ten('movie').length).must_equal 10
    end
  end
end
