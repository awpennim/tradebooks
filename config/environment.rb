# Load the rails application
require File.expand_path('../application', __FILE__)

ActionMailer::Base

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :user_name => "awpennim",
  :password => "hahiqua",
  :domain => "www.tradecampusbooks.com",
  :address => "smtp.sendgrid.net",
  :port => 587,
  :enable_starttls_auto => true,
  :authentication => :plain
}

# Initialize the rails application
Zoomasstextbooks::Application.initialize!

RCC_PUB = '6Lc4acwSAAAAAMmysjig5psn13XVwaTwHRYsujoe'
RCC_PRIV = '6Lc4acwSAAAAAL8yBEhrlD4S_uHa6H99kCtj76NI'


