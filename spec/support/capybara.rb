require 'capybara/poltergeist'

# Use this driver to start firefox with a profile called firebug, where you can leave firebug installed.
# In OSX, run '/Applications/Firefox.app/Contents/MacOS/firefox-bin -p' to create a profile.
Capybara.register_driver :selenium_firebug do |app|
  Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => "firebug")
end

#Capybara.javascript_driver = :selenium_firebug
#Capybara.javascript_driver = :poltergeist
Capybara.javascript_driver = :selenium
