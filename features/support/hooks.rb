
at_exit do
  # noinspection RubyResolve,RubyResolve
  $browser.quit
  app_info 'Test run completed'
end