class V1::ApiController < ApplicationController
  include ApiHelper
  include NotificationHelper

  before_action :init
  before_action :restrict_access, except: [
    # List of route methods that do not need authentication
    :request_get,
    :request_post,
    :auth,
    :reset_password,
    :update_password,
    :check_email,
    :version_ios,
    :version_android
  ]

  ##############################################################################
  # Calls that don't require access_token
  ##############################################################################
  def request_get
    render json: { 'body' => 'GET Request' }, status: :ok
  end

  def request_post
    render json: { 'body' => "POST Request: #{request.body.read}" }, status: :ok
  end

  def auth
    # Alternative to users_get call that returns the User token in addition to
    # the rest of the model, provided proper authentication is given.

    unless request.headers['Content-Type'] == 'application/x-www-form-urlencoded'
      error_array = ['must be application/x-www-form-urlencoded']
      if request.headers['Content-Type'].present?
        error_array.push('cannot be ' + request.headers['Content-Type'])
      else
        error_array.push('cannot be nil')
      end
      errors = { content_type: error_array }
      raise BadRequest.new(errors)
    end
    if params[:user].blank?
      errors = { email: ['cannot be blank'], password: ['cannot be blank'] }
      raise BadRequest.new(errors)
    end
    if params[:user][:email].blank?
      errors = { email: ['cannot be blank'] }
      raise BadRequest.new(errors)
    end
    if params[:user][:password].blank?
      errors = { password: ['cannot be blank'] }
      raise BadRequest.new(errors)
    end
    user = User.find_by(email: params[:user][:email])
    return head :not_found unless user
    # Log this authentication event
    ip_addr = IPAddr.new(request.remote_ip)
    auth_event = AuthEvent.new(ip_address: ip_addr)
    auth_event.user = user
    user = user.try(:authenticate, params[:user][:password])
    unless user
      auth_event.success = false
      auth_event.save!
      errors = { password: ['is incorrect'] }
      return render json: errors, status: :unauthorized
    end
    auth_event.success = true
    auth_event.save!
    if user.token.blank?
      # Generate access token for User
      user.generate_token
      # Save and check for validation errors
      raise UnprocessableEntity.new(user.errors) unless user.save
    end
    # Send User model with token
    render json: user.with_token, status: :ok
  end

  def reset_password
    unless params[:user] && params[:user][:email]
      errors = { email: 'is required' }
      raise BadRequest.new(errors)
    end

    user = User.find_by(email: params[:user][:email])
    return head :not_found unless user

    token = user.generate_password_reset
    user.save!
    UserMailer.password_reset(user, token).deliver_now
    head :ok
  end

  def update_password
    errors = {}
    if params[:user].blank?
      errors = {
        email: 'is required',
        password: 'is required'
      }
      raise BadRequest.new(errors)
    else
      errors[:email] = 'is required' if params[:user][:email].blank?
      errors[:password] = 'is required' if params[:user][:password].blank?
    end
    errors[:token] = 'is required' if params[:token].blank?
    raise BadRequest.new(errors) unless errors.blank?

    user = User.find_by(email: params[:user][:email])
    return head :not_found unless user

    unless user.reset_password_token && user.reset_password_sent_at
      errors = { token: 'has never been requested' }
      raise BadRequest.new(errors)
    end

    diff = DateTime.current - user.reset_password_sent_at.to_datetime
    # Difference between DateTimes is in days, convert to seconds
    diff *= 1.days
    unless diff.between?(0.seconds, 10.minutes)
      errors = { token: 'is expired' }
      return render json: errors, status: :bad_request
    end

    unless params[:token] == user.reset_password_token
      errors = { token: 'is incorrect' }
      return render json: errors, status: :bad_request
    end

    unless user.update(password: params[:user][:password])
      raise UnprocessableEntity.new(user.errors)
    end

    head :ok
  end

  def check_email
    user = User.find_by(email: params[:email])
    return render json: { 'email' => 'exists' }, status: :ok if user
    render json: { 'email' => 'does not exist' }, status: :ok
  end

  def version_ios
    render json: { 'version' => '0.0.1' }, status: :ok
  end

  def version_android
    render json: { 'version' => '0.0.1' }, status: :ok
  end

  ##############################################################################
  # Calls requiring access_token
  ##############################################################################

  # None
end
