class V1::WebhooksController < ApplicationController
  include SlackHelper

  before_action :init
  # No webhooks require authentication

  def twilio
    logger.info "From:"
    logger.info params[:From]
    logger.info "Body:"
    logger.info params[:Body]
    SlackHelper.log("Twilio:\n```" + params.inspect + '```')
    head :ok
  end
end
