# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password
  has_many :microposts, dependent: :destroy
  
  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token

  validates :name,
    presence: true,
    length: { maximum: 50 }

  validates :password,
    presence: true,
    length: { minimum: 6 }

  validates :password_confirmation,
    presence: true

  validates :email,
    presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: VALID_EMAIL_REGEX }

  def feed
    # @TODO: Preliminary. See "Following Users"
    Micropost.where("user_id = ?", id)
  end

  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
