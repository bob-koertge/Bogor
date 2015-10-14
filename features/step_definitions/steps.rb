Transform /^(-?\d+)$/ do |number|
  number.to_i
end

Given(/^I am on a new site$/) do
  # noinspection RubyResolve,RubyResolve
  $browser.navigate.to 'https://support.desk.com'
end

Given /^I request the status of (\w*)/ do |arg1|
  $site_url = 'https:/support.desk.com'
  case arg1
    when 'api', 'poll'
      # noinspection RubyResolve,RubyResolve
      $browser.navigate.to "#{$data_store[:site_info][:site_url]}/#{arg1}/status"
    when 'portal'
      # noinspection RubyResolve,RubyResolve
      $browser.navigate.to "#{$data_store[:site_info][:site_url]}/customer/portal/status1"
    else
      app_error 'Endpoint not supported'
  end
end

Then(/^The system returns the current status$/) do
  # noinspection RubyResolve,RubyResolve
  expect($browser.find_element(:tag_name => 'body').text).to eq('OK')
end
Given(/^I*\s*seed (\d+) (\w+) email[s]*$/) do |qty,type|
  seed_data = SeedDataApiHelper.new $data_store
  seed_data.create_case('email',qty,type)

end
Given(/^I create a new site via api$/) do
  response = HTTParty.post("#{PROTOCOL}reg.#{DOMAIN}#{TLD}/api/v2/site",
                           {
                               body: {
                                   password: $data_store[:site_info][:user_password],
                                   subdomain: $data_store[:site_info][:site_name],
                                   contact_phone: '111-111-1111',
                                   contact_name: 'Bob Koertge',
                                   contact_email: $data_store[:site_info][:user_email]
                               }.to_json,
                               headers: {'Content-Type' => 'application/json', 'Accept' => 'application/json'},
                               verify: false
                           })
  app_error "Unable to create site via API" unless response.code == 201
  app_info "Created site #{$data_store[:site_info][:site_name]}"
  step 'the site should exist'
end

Then(/^the site should exist$/) do
  $browser.navigate.to "#{$data_store[:site_info][:site_url]}/status"
  wait = Selenium::WebDriver::Wait.new(:timeout => 60)
  result = wait.until {
    $browser.find_element(:tag_name => 'body').text
  }
  expect(result).to eq('OK')
end
Then(/^I wait for postmark to send in first case$/) do
  email_helper = EmailHelper.new $data_store
  expect(email_helper.wait_for_postmark).to eql(true)
end

