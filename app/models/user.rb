class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token

  scope :newest, -> { order(created_at: :desc) }

  validates :name, presence: true,
                   length: { in: 1..50, too_long: I18n.t('users.warnings.max_length_50'),
                             too_short: I18n.t('users.warnings.min_length_1') }

  validates :email, presence: true, length: { maximum: Settings.max_255 },
                    format: { with: Regexp.new(Settings.VALID_EMAIL_REGEX) }, uniqueness: true
  validates :password, presence: true, length: { minimum: Settings.digit_6 },
                       allow_nil: true
  has_secure_password

  before_create :create_activation_digest
  before_save :downcase_email
  around_save :callback_around_save
  after_update :run_callback_after_update

  def callback_around_save
    Rails.logger.debug 'in around save'
    yield
    Rails.logger.debug 'out around save'
  end

  def run_callback_after_update
    Rails.logger.debug 'Callback after update is called!'
  end

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  class << self
    def digest(string)
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    remember_digest
  end

  def authenticated?(remember_token)
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_column :remember_digest, nil
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
end
