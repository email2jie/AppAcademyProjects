class User < ActiveRecord::Base
  attr_accessible :email, :password
  attr_reader :password

  before_validation :set_session_token
  validates_presence_of :email, :password_digest, :session_token,
                        :reset_token
  validates :password, :length => { :minimum => 6, :allow_nil => true }

  has_many :inbound_friends,
           :class_name => "Friend",
           :foreign_key => :friender_id

  has_many :outbound_friends,
           :class_name => "Friend",
           :foreign_key => :friended_id

  has_many :circles

  has_many :circle_memberships

  has_many :friends,
           :through => :outbound_friends,
           :source => :friended_user

  has_many :frienders,
           :through => :inbound_friends,
           :source => :friender

  def self.find_by_credentials(user_hash)
    user = User.find_by_email(user_hash[:email])
    return user if !!user && user.is_password?(user_hash[:password])
    nil
  end

  def password=(raw_pass)
    self.password_digest = BCrypt::Password.create(raw_pass)
  end

  def is_password?(pass)
    BCrypt::Password.new(self.password_digest) == pass
  end

  def reset_session_token!
    self.set_session_token
    self.save
    self.session_token
  end

  #The token is for password resets, sadly it causes this method to
  #have a confusing name
  def reset_reset_token!
    self.set_reset_token
    self.save
    self.reset_token
  end

  def set_session_token
    self.session_token = SecureRandom.urlsafe_base64(16)
  end

  def set_reset_token
    self.reset_token = SecureRandom.urlsafe_base64(16)
  end
end
