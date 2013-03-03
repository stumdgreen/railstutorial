class Micropost < ActiveRecord::Base
  attr_accessible :content
  belongs_to :user
  MAXIMUM_CHARACTERS = 140

  validates :content, presence: true, length: { maximum: MAXIMUM_CHARACTERS }
  validates :user_id, presence: true
  default_scope order: 'microposts.created_at DESC'
end
