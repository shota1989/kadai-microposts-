class Micropost < ApplicationRecord
  belongs_to :user
  has_many :relationship2s 
  
  validates :content, presence: true, length: { maximum: 255 }
end
