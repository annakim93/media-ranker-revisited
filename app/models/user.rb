class User < ApplicationRecord
  has_many :votes, dependent: :destroy
  has_many :ranked_works, through: :votes, source: :work
  has_many :works, dependent: :destroy

  validates :username, :email, uniqueness: true, presence: true
  validates :uid, uniqueness: { scope: :provider }, presence: true

  def self.build_from_github(auth_hash)
    user = User.new
    user.uid = auth_hash[:uid]
    user.provider = 'github'
    user.username = auth_hash[:info][:name]
    user.email = auth_hash[:info][:email]
    return user
  end
end
