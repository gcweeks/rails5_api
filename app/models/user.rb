class User < ApplicationRecord
  PASSWORD_FORMAT = /\A
  (?=.{9,})          # Must contain 9 or more characters
  # (?=.*\d)           # Must contain a digit
  # (?=.*[a-z])        # Must contain a lower case character
  # (?=.*[A-Z])        # Must contain an upper case character
  # (?=.*[[:^alnum:]]) # Must contain a symbol
  /x

  has_many :auth_events
  has_many :fcm_tokens
  has_secure_password

  # Validations
  validates :email, presence: true, uniqueness: true, format: {
    with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  }
  validates :password, presence: true, format: { with: PASSWORD_FORMAT },
                       on: :create
  validates :password, allow_nil: true, format: { with: PASSWORD_FORMAT },
                       on: :update
  validates :fname, presence: true
  validates :lname, presence: true
  validates :dob, presence: true
  validates :token, presence: true
  validate :valid_phone?
  validate :common_password?

  def valid_phone?
    if self.phone
      phone = self.phone
      # Check if number is exactly 10 digits (Convert to int then back to
      # string, then make sure result is the same. Pad with zeros in case phone
      # starts with zero, as this would drop out in integer conversion.)
      if phone.length != 10 || ("%010d" % phone.to_i.to_s != phone)
        errors.add(:phone, 'must be exactly 10 digits')
      end
      return
    end
    errors.add(:phone, 'is required')
  end

  def common_password?
    common = File.join(Rails.root, 'config', 'common_passwords.txt')
    File.readlines(common).each do |line|
      if self.password == line.chomp
        errors.add(:password, 'is too common')
        return
      end
    end
  end

  def as_json(options = {})
    json = super({
      except: [:token, :password_digest, :reset_password_token,
               :reset_password_sent_at , :confirmation_token,
               :confirmation_sent_at, :failed_attempts, :unlock_token,
               :locked_at
      ]
    }.merge(options))
    # Manually call as_json (implicitly) for fields that are models
    # json['address'] = address
    json
  end

  def with_token
    json = as_json
    json['token'] = token
    json
  end

  def generate_token
    self.token = SecureRandom.base58(24)
  end

  def generate_password_reset
    self.reset_password_sent_at = DateTime.current
    self.reset_password_token = SecureRandom.base58(6)
  end
end
