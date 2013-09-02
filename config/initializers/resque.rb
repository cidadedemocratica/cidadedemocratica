require 'resque'

Resque::Mailer.excluded_environments = [:test, :development, :staging]

Resque::Server.use(Rack::Auth::Basic) do |user, password|
  user == "admin"
  password == ENV['RESQUE_ADMIN_PASSWORD']
end

