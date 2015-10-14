class DeskQATestHelper

  def initialize(data_store, browser)
    @@data_store = data_store
    @@browser = browser
  end

  def login(endpoint)
    @@browser.navigate.to "#{@@data_store[:site_info][:site_url]}/#{endpoint}"
    @@browser.find_element(name: 'user_session[email]').send_keys @@data_store[:site_info][:user_email]
    @@browser.find_element(name: 'user_session[password]').send_keys @@data_store[:site_info][:user_password]
    @@browser.find_element(id: 'user_session_submit').click
    wait = Selenium::WebDriver::Wait.new(:timeout => 10)
    wait.until {
      @@browser.find_element(class: 'modal-backdrop')
    }
    @@browser.find_element(xpath: '/html/body/div[4]/div/div/div/div/div[2]/a').click
    wait.until {
      @@browser.find_element(xpath: '/html/body/div[4]/div[1]/div/div/button')
    }
    @@browser.find_element(xpath: '/html/body/div[4]/div[1]/div/div/button').click
    @@browser.find_element(class: 'ds-avatar').displayed?
  end

end