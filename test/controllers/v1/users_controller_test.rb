require 'test_helper'

class V1::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    host! 'localhost:3000/v1/users/'
    @user = users(:user1)
    @user.password = 'Abcde_12345'
    @user.generate_token
    @user.save!
    @headers = { 'Authorization' => @user.token }
    # initialize_someservice_stubs
  end

  test 'should create' do
    # Missing email
    post '/', params: { user: { password: @user.password,
                                fname: @user.fname,
                                lname: @user.lname,
                                dob: @user.dob,
                                phone: @user.phone
                              } }
    assert_response :unprocessable_entity
    # Invalid email
    post '/', params: { user: { email: 'bad@email',
                                password: @user.password,
                                fname: @user.fname,
                                lname: @user.lname,
                                dob: @user.dob,
                                phone: @user.phone
                              } }
    assert_response :unprocessable_entity
    # Existing email
    post '/', params: { user: { email: @user.email,
                                password: @user.password,
                                fname: @user.fname,
                                lname: @user.lname,
                                dob: @user.dob,
                                phone: @user.phone
                              } }
    assert_response :unprocessable_entity
    new_email = 'new@email.com'
    # Missing password
    post '/', params: { user: { email: new_email,
                                fname: @user.fname,
                                lname: @user.lname,
                                dob: @user.dob,
                                phone: @user.phone
                              } }
    assert_response :unprocessable_entity
    # Invalid password
    post '/', params: { user: { email: new_email,
                                password: 'short',
                                fname: @user.fname,
                                lname: @user.lname,
                                dob: @user.dob,
                                phone: @user.phone
                              } }
    assert_response :unprocessable_entity
    # Missing fname
    post '/', params: { user: { email: new_email,
                                password: @user.password,
                                lname: @user.lname,
                                dob: @user.dob,
                                phone: @user.phone
                              } }
    assert_response :unprocessable_entity
    # Missing lname
    post '/', params: { user: { email: new_email,
                                password: @user.password,
                                fname: @user.fname,
                                dob: @user.dob,
                                phone: @user.phone
                              } }
    assert_response :unprocessable_entity
    # Missing dob
    post '/', params: { user: { email: new_email,
                                password: @user.password,
                                fname: @user.fname,
                                lname: @user.lname,
                                phone: @user.phone
                              } }
    assert_response :unprocessable_entity
    # Missing phone
    post '/', params: { user: { email: new_email,
                                password: @user.password,
                                fname: @user.fname,
                                lname: @user.lname,
                                dob: @user.dob
                              } }
    assert_response :unprocessable_entity
    # Valid User
    post '/', params: { user: { email: new_email,
                                password: @user.password,
                                fname: @user.fname,
                                lname: @user.lname,
                                dob: @user.dob,
                                phone: @user.phone
                              } }
    assert_response :success

    # Check Response
    res = JSON.parse(@response.body)
    assert_equal 24, res['token'].length
    assert_equal res['fname'], @user.fname
    assert_equal res['lname'], @user.lname
    assert_equal res['email'], new_email
    assert_equal res['dob'], @user.dob.to_s
    assert_equal res['phone'], @user.phone
  end

  test 'should get me' do
    # Requires auth
    get 'me'
    assert_response :unauthorized

    get 'me', headers: @headers
    assert_response :success

    # Check Response
    res = JSON.parse(@response.body)
    assert_equal res['fname'], @user.fname
    assert_equal res['lname'], @user.lname
    assert_equal res['email'], @user.email
    assert_equal res['dob'], @user.dob.to_s
    assert_equal res['phone'], @user.phone
  end

  test 'should update me' do
    # Requires auth
    put 'me'
    assert_response :unauthorized

    fname = 'Test'
    lname = 'User'
    password = 'NewPa55word'
    phone = '5555555555'
    put 'me', headers: @headers, params: {
      user: {
        fname: fname,
        lname: lname,
        phone: phone,
        password: password
      }
    }
    assert_response :success

    res = JSON.parse(@response.body)
    assert_equal res['fname'], fname
    assert_equal res['lname'], lname
    assert_equal res['phone'], phone

    # Assert new password works and old one doesn't
    host! 'localhost:3000/v1/'
    get 'auth', headers: {
      'Content-Type' => 'application/x-www-form-urlencoded'
    }, params: {
      user: {
        email: @user.email,
        password: password
      }
    }
    assert_response :success
    res = JSON.parse(@response.body)
    assert_equal @user.token, res['token']
    get 'auth', headers: {
      'Content-Type' => 'application/x-www-form-urlencoded'
    }, params: {
      user: {
        email: @user.email,
        password: @user.password
      }
    }
    assert_response :unauthorized
    host! 'localhost:3000/v1/users/'
  end

  test 'should register push token' do
    # Requires auth
    post 'me/register_push_token'
    assert_response :unauthorized

    # Requires a token
    post 'me/register_push_token', headers: @headers
    assert_response :bad_request
    res = JSON.parse(@response.body)
    assert_equal res['token'], ['is required']

    # Ensure no token already exists
    fcm_token_string_1 = '1234'
    fcm_token = FcmToken.find_by(token: fcm_token_string_1)
    assert_nil fcm_token

    # Register token
    post 'me/register_push_token', headers: @headers, params: {
      token: fcm_token_string_1
    }
    assert_response :ok
    res = JSON.parse(@response.body)
    assert_equal res['status'], 'registered'

    # Ensure token was successfully registered
    @user.reload
    fcm_token = FcmToken.find_by(token: fcm_token_string_1)
    assert_not_nil fcm_token
    assert_equal fcm_token.token, fcm_token_string_1
    assert_equal fcm_token.user_id, @user.id

    # Add another token
    fcm_token_string_2 = '5678'
    post 'me/register_push_token', headers: @headers, params: {
      token: fcm_token_string_2
    }
    assert_response :ok
    res = JSON.parse(@response.body)
    assert_equal res['status'], 'registered'
    @user.reload
    # Ensure User still has both tokens
    # Token 1
    fcm_token = FcmToken.find_by(token: fcm_token_string_1)
    assert_not_nil fcm_token
    assert_equal fcm_token.token, fcm_token_string_1
    assert_equal fcm_token.user_id, @user.id
    # Token 2
    fcm_token = FcmToken.find_by(token: fcm_token_string_2)
    assert_not_nil fcm_token
    assert_equal fcm_token.token, fcm_token_string_2
    assert_equal fcm_token.user_id, @user.id

    # Change Token 1 User
    # Create new User
    user_2 = User.new
    user_2.fname = @user.fname
    user_2.lname = @user.lname
    user_2.email = 'new@email.com'
    user_2.dob = @user.dob
    user_2.phone = @user.phone
    user_2.password = 'Abcde_12345'
    user_2.generate_token
    user_2.save!
    # Register token
    user_2_headers = { 'Authorization' => user_2.token }
    post 'me/register_push_token', headers: user_2_headers, params: {
      token: fcm_token_string_1
    }
    assert_response :ok
    res = JSON.parse(@response.body)
    assert_equal res['status'], 'registered'
    # Ensure user_2 has token
    user_2.reload
    fcm_token = FcmToken.find_by(token: fcm_token_string_1)
    assert_not_nil fcm_token
    assert_equal fcm_token.token, fcm_token_string_1
    assert_equal fcm_token.user_id, user_2.id
  end
end
