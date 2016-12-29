ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'webmock'
include WebMock::API
WebMock.enable!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def fixture_json(name)
    JSON.parse(File.read('test/fixtures/files/' + name + '.json'))
  end

  def fixture(name)
    fixture_json(name).to_json
  end

  # Stubs

  def stub_someservice(method, path, body: {}, query: {}, status: 200, response: nil, response_headers: nil, host: 'someservice.com')
    # headers = {}
    # headers['Accept'] = '...'
    #
    # expectations = {}
    # expectations[:headers] = headers unless headers.empty?
    # expectations[:body] = body unless body.empty?
    # expectations[:query] = query unless query.empty?
    #
    # stub = stub_request(method, "https://#{host}/#{path}")
    # stub = stub.with(expectations) unless expectations.empty?
    #
    # if response_headers
    #   response_headers = JSON.parse(response_headers)
    # else
    #   response_headers = {}
    # end
    # response_headers['content-type'] = "..."
    #
    # stub.to_return(status: status, body: response, headers: response_headers)
  end

  def initialize_someservice_stubs(user)
    # json = fixture_json('someservice_somefixture')
    # body = {
    #   firstName: user.fname,
    #   lastName: user.lname
    # }
    # stub_someservice :post, 'someroute', body: body, status: 201, response_headers: json
  end

  # Add more helper methods to be used by all tests here...
end
