# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Zoomasstextbooks::Application.initialize!

RCC_PUB = '6Lc4acwSAAAAAMmysjig5psn13XVwaTwHRYsujoe'
RCC_PRIV = '6Lc4acwSAAAAAL8yBEhrlD4S_uHa6H99kCtj76NI'

ActionMailer::Base.delivery_method = :smtp

ActionMailer::Base.smtp_settings = {
  :user_name => "support@tradecampusbooks.com",
  :password => "hahiqua",
  :domain => "www.tradecampusbooks.com",
  :address => "smtpout.secureserver.net",
  :port => 80,
  :enable_starttls_auto => true,
  :authentication => :plain
}
