set :output, "log/whenever.log"

every 1.day, :at => '0:05am' do
  rake "cd:update_phases"
end
