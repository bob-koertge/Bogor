Given(/^I am on a new site$/) do
  # noinspection RubyResolve,RubyResolve
  $browser.navigate.to 'https://support.desk.com'
end

Given /^I request the status of (\w*)/ do |arg1|
  $site_url = 'https:/support.desk.com'
  case arg1
    when 'api', 'poll'
      # noinspection RubyResolve,RubyResolve
      $browser.navigate.to "#{$site_url}/#{arg1}/status"
    when 'portal'
      # noinspection RubyResolve,RubyResolve
      $browser.navigate.to "#{$site_url}/customer/portal/status1"
    else
      app_error 'Endpoint not supported'
  end
end

Then(/^The system returns the current status$/) do
  # noinspection RubyResolve,RubyResolve
   expect($browser.find_element(:tag_name => 'body').text).to eq('OK')
end

