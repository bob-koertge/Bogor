class EmailHelper
  require 'rspec/expectations'
  attr_accessor :data_store

  def initialize(data_store)
    @@data_store = data_store

    @@connection ||= Faraday.new(:url => data_store[:site_info][:site_url], :ssl => {:verify => false}) do |farday|
      #  farday.response :logger if DEBUG
      farday.use Faraday::Adapter::NetHttp
    end
    @@connection.basic_auth(data_store[:site_info][:user_email], data_store[:site_info][:user_password])

  end

  def wait_for_postmark
    count = 0
    postmark_email_found = false
    begin
      sleep(5)
      cases = get_all('cases')
      count += 1
      cases.each do |ticket|
        (ticket['subject'] == 'Your free support email address has been activated.') ?
            postmark_email_found = true :
            postmark_email_found = false
      end
    end until postmark_email_found || count > 10
    postmark_email_found
  end

  private
  def get_all(endpoint)
    #TODO add rate limiting
    return_value = Hash.new
    response = @@connection.get "/api/v2/#{endpoint}"
    response = JSON.parse(response.body)
    loop do
      return_value = response['_embedded']['entries']
      break if response['_links']['next'].nil?
      response = @@connection.get response['_links']['next']['href']
      response = JSON.parse(response.body)
    end
    return_value
  end
end