class ApplicationMailer < ActionMailer::Base
  default from: "SomeCompany <donotreply@somecompany.com>"
  layout 'mailer'
end
