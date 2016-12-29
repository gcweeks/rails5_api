require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'validations' do
    user = users(:user1)

    assert_not user.save, 'Saved User without token'
    user.generate_token

    # Password
    assert_not user.save, 'Saved User without password'
    password = 'Abcde_12345'
    user.password = password
    assert user.save, "Couldn't save valid User"
    user.reload
    user.password = 'Abcd'
    assert_not user.save, 'Saved User with short password'
    user.password = password

    # Email
    email = user.email
    user.email = nil
    assert_not user.save, 'Saved User without email'
    user.email = '@gmail.com'
    assert_not user.save, 'Saved User with improper email format 1'
    user.email = 'cashmoney@gmail.'
    assert_not user.save, 'Saved User with improper email format 2'
    user.email = email
    new_user = User.new(fname: user.fname, lname: user.lname, dob: user.dob,
                        email: user.email, password: 'password')
    new_user.generate_token
    assert_not new_user.save, 'Saved new User with duplicate email'

    # Name
    fname = user.fname
    user.fname = ''
    assert_not user.save, 'Saved User without first name'
    user.fname = fname
    lname = user.lname
    user.lname = nil
    assert_not user.save, 'Saved User without last name'
    user.lname = lname

    # DOB
    dob = user.dob
    user.dob = nil
    assert_not user.save, 'Saved User without dob'
    user.dob = dob

    # Phone
    phone = user.phone
    user.phone = nil
    assert_not user.save, 'Saved User without phone'
    user.phone = '123456789' # Too short
    assert_not user.save, 'Saved User with invalid phone'
    user.phone = '12345678901' # Too long
    assert_not user.save, 'Saved User with invalid phone'
    user.phone = '1-34567890' # Not a number
    assert_not user.save, 'Saved User with invalid phone'
    user.phone = phone
    assert user.save, "Couldn't save valid User"
    # user.reload
  end

  test 'should generate token' do
    user = users(:user1)

    # Token
    assert_nil user.token
    user.generate_token
    assert_not_nil user.token
  end
end
