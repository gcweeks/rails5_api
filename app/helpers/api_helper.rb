module ApiHelper
  include TwilioHelper
  require 'date'
  require 'digest'

  def confirm_code(number, code)
    # Test User case:
    return true if number == '+15555550001' && code == '0001'
    # Get possible codes
    current_code = generate_confirmation(number, false)
    late_code = generate_confirmation(number, true)
    code == current_code || code == late_code
  end

  def sms_send_confirmation(number)
    code = generate_confirmation(number, false)
    body = 'Your confirmation code is ' + code + '.\nSomeCompany'
    send_twilio_sms(number, body)
  end

  private

  def generate_confirmation(number, late)
    # Get current hour for hash
    now = Time.current.beginning_of_hour
    # Consider confirmation codes where the hour changes before the user
    # can confirm it
    now -= 1.hour if late
    # Combine with number, key and salt
    str = number + now.to_s + @SALT
    # SHA256 hash
    digest = Digest::SHA256.hexdigest(str)
    # Convert to decimal 6-digit number
    code = digest.to_i(16).to_s(10)[9..14]
    code
  end
end
