module TwilioHelper
  require 'twilio-ruby'
  include SlackHelper

  def init_twilio
    @TWILIO_SID = ENV['TWILIO_SID']
    @TWILIO_TOKEN = ENV['TWILIO_TOKEN']
    @TWILIO_NUMBER = '+15555555555'
  end

  def twilio_generate_response(message)
    twiml = Twilio::TwiML::Response.new do |r|
      r.Message(message)
    end
    twiml.text
  end

  def send_twilio_sms(to, body)
    init_twilio
    send_twilio_sms_with_number(@TWILIO_NUMBER, to, body)
  end

  def send_twilio_sms_with_number(twilio_number, to, body)
    return true if to == '+15555550001' # Test User
    # Set up a client to talk to the Twilio REST API
    init_twilio
    client = Twilio::REST::Client.new @TWILIO_SID, @TWILIO_TOKEN
    # Send message
    begin
      client.account.messages.create(
        from: twilio_number,
        to: to,
        body: body
      )
    rescue => e
      logger.info e.message
      SlackHelper.log(e.message)
      return false
    end
    true
  end
end
