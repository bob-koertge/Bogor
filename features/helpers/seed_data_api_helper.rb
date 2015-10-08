class SeedDataApiHelper

  attr_accessor :data_store
  OLDEST_CASE_IN_DAYS = 700
  def initialize(data_store)
    @@supported_case_priorities = [*1..10]
    @@supported_case_statues = [:new, :open, :pending, :resolved, :closed]
    @@supported_case_types = [:chat, :twitter, :email, :qna, :phone]
    @@contact_information = [:work, :home, :mobile, :other]
    @@site_config = {sitename: data_store[:site_info][:site_url], username: data_store[:site_info][:user_email], password: data_store[:site_info][:user_password]}
    @data_store = data_store

    @@connection ||= Faraday.new(:url => data_store[:site_info][:site_url],:ssl => {:verify => false}) do |farday|
      #  farday.response :logger if DEBUG
      farday.use Faraday::Adapter::NetHttp
    end
    @@connection.basic_auth(data_store[:site_info][:user_email], data_store[:site_info][:user_password])
  end

  def dump_var
    ap @@site_config
  end

  def create_customer(qty=5)
    qty.times do
      endpoint = '/api/v2/customers'
      body = {
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          company: Faker::Company.name,
          title: Faker::Name.title,
          background: Faker::Lorem.sentence(Random.rand(0...50)),
          emails: [{
                       type: @@contact_information.sample.to_s,
                       value: Faker::Internet.safe_email
                   }],
          phone_numbers: {
              type: @@contact_information.sample.to_s,
              value: Faker::PhoneNumber.phone_number
          },
          addresses: [{
                          type: @@contact_information.sample.to_s,
                          value: Faker::Address.street_address
                      }]
      }
      create(endpoint, body)
    end
  end

  def create_case(type, qty)
    create_customer
    @customers = customers
    qty.to_i.times do
      endpoint = "/api/v2/customers/#{@customers.sample['id']}/cases"
      body = {
          type: type,
          subject: Faker::Hacker.say_something_smart,
          priority: @@supported_case_priorities.sample,
          status: @@supported_case_statues.sample.to_s,
          suppress_rules: true,
          created_at: Faker::Time.between(OLDEST_CASE_IN_DAYS.days.ago, Time.now, :all),
          labels: [(Faker::Lorem.words(Random.rand(0...50)))],
      }
      case type
        when 'email'
          body[:message] = {
              direction: 'in',
              body: "#{Faker::Lorem.paragraph(2)}",
              to: "#{Faker::Internet.safe_email}",
              from: "#{Faker::Internet.safe_email}",
              subject: body[:subject]
          }
        else
          app_error 'Unsupported Channel for case creation'
      end
      create(endpoint, body)
    end
  end

  def customers
    get_all(__callee__)
  end
  private

  def create(endpoint, body)
    res = @@connection.post do |req|
      req.url endpoint
      req.headers['Content-Type'] = 'application/json'
      req.body = body.to_json
    end
    app_info "Created #{endpoint} #{JSON.parse(res.body)['id']}" if res.status == 201
    app_error "Error #{res.status} - #{res.body}" if res.status != 201
    res
  end

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