require 'selenium-webdriver'
require 'ap'
require 'logger'
require 'yaml'
require 'rspec/expectations'
require 'sauce_whisk'
require 'httparty'
require 'securerandom'
require 'faker'
require 'faraday'
require 'as-duration'

PROTOCOL = 'https://'
DOMAIN = 'deskstaging'
TLD = '.com'
$sitename = "zzz-bobtest1-#{SecureRandom.hex}"
$data_store= Hash.new
$data_store[:site_info] = {
  site_url: "#{PROTOCOL}#{$sitename}.#{DOMAIN}#{TLD}",
  site_name: $sitename,
  user_email: 'bob@desk.com',
  user_password: 'Test1234'
}

$log = Logger.new('log/smoke_test.log')

def app_error(msg)
  if running_in_parallel?
    msg = "Process ##{parallel_process_number} - #{msg}"
  end
  $log.error msg
  abort msg
end

def app_info(msg)
  if running_in_parallel?
    msg = "Process ##{parallel_process_number} - #{msg}"
  end
  $log.info msg
end

def is_env_var_set(variables_to_check)
  variables_to_check.each do |variable_to_check|
    if ENV[variable_to_check] == nil
      app_error "System Variable #{variable_to_check} is not set"
    end
  end
end

def running_in_parallel?
  (ENV['AUTOTEST'] == '1') ?  true :  false
end

def parallel_process_number
  if running_in_parallel?
   return 1 if ENV['TEST_ENV_NUMBER'] == nil
   return ENV['TEST_ENV_NUMBER']
  end
  0
end
is_env_var_set(['TEST_SERVICE'])
required_env_var = %w(TEST_BROWSER)

case ENV['TEST_SERVICE'].downcase
  when 'local'
    app_info 'Running tests on local machine'
    required_env_var = required_env_var + %w()
    is_env_var_set required_env_var
    begin
      $browser = Selenium::WebDriver.for ENV['TEST_BROWSER'].to_sym
    rescue ArgumentError
      app_error "#{ENV['TEST_BROWSER']} is not a supported browser for local testing."
    end
  when 'sauce'
    #TODO name test for reference in Sauce Labs
    app_info 'Running tests on Sauce Labs'
    required_env_var = required_env_var + %w(SAUCE_USERNAME SAUCE_ACCESS_KEY)
    is_env_var_set required_env_var

    begin
      caps = YAML.load_file("config/sauce_browsers/#{ENV['TEST_BROWSER']}.yml")
    rescue Errno::ENOENT
      app_error "No configuration file found for #{ENV['TEST_BROWSER']}"
    end

    sauce_endpoint = "http://#{ENV['SAUCE_USERNAME']}:#{ENV['SAUCE_ACCESS_KEY']}@ondemand.saucelabs.com:80/wd/hub"
    $browser = Selenium::WebDriver.for :remote, :url => sauce_endpoint, :desired_capabilities => caps
  else
    app_error "Unknown test service #{ENV['TEST_SERVICE']} specified."
end





