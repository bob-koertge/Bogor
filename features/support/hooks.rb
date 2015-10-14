Before do |scenario|
  case ENV['TEST_SERVICE'].downcase
    when 'local'
    when 'sauce'
      @job_id = $browser.session_id
      app_info "Sauce Job ID is #{@job_id}"
      job = SauceWhisk::Jobs.fetch @job_id
      @job_name = "Bogor - #{scenario.name}"
      job.name = @job_name
      job.save
      app_info "Sauce Job ID #{@job_id} named #{job.name}"
    else
      app_error "Unknown test service #{ENV['TEST_SERVICE']} specified."
  end
end

After do |scenario|
  if ENV['TEST_SERVICE'].downcase == 'sauce'
    if scenario.failed?
      SauceWhisk::Jobs.fail_job @job_id
      app_error "#{@job_name} failed"
    end
    SauceWhisk::Jobs.pass_job @job_id if scenario.passed?
      app_info "#{@job_name} passed"
  end
end
at_exit do
  # noinspection RubyResolve,RubyResolve
#  $browser.quit
  app_info 'Test run completed'
end