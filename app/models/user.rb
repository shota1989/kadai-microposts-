class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password

  has_many :microposts
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user
 
  has_many :relationship2s
  has_many :likes, through: :relationship2s, source: :micropost
  
  # like/Unlike
  def like(post)
    self.relationship2s.find_or_create_by(micropost_id: post.id)
  end

  def unlike(post)
    relationship2 = self.relationship2s.find_by(micropost_id: post.id)
    relationship2.destroy if relationship2
  end 
  
  def liking?(post)
    self.likes.include?(post)
  end
  
  def feed_likes
    Micropost.where(id: self.like_ids)
  end 

  # フォロー/アンフォロー
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end
  
  def following?(other_user)
    self.followings.include?(other_user)
  end
  
  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
  
end