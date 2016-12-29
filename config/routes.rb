Rails.application.routes.draw do
  namespace :v1 do
    resources :users, only: [:create]

    # Calls that do not requre an access token
    get  '/'                        => 'api#request_get'
    post '/'                        => 'api#request_post'
    get  'auth'                     => 'api#auth'
    post 'reset_password'           => 'api#reset_password'
    put  'update_password'          => 'api#update_password'
    get  'check_email'              => 'api#check_email'
    scope 'version' do
      get 'ios'     => 'api#version_ios'
      get 'android' => 'api#version_android'
    end
    scope 'webhooks' do
      get  'twilio' => 'webhooks#twilio'
    end

    # Model-specific calls (other than those created by resources)
    scope 'users' do
      scope 'me' do
        get    '/'                        => 'users#get_me'
        put    '/'                        => 'users#update_me'
        post   'register_push_token'      => 'users#register_push_token'
        post   'support'                  => 'users#support'
        post   'dev_notify'               => 'users#dev_notify'
        post   'dev_email'                => 'users#dev_email'
      end
    end
  end
end
