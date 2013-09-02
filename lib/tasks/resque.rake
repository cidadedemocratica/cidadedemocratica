# -*- encoding : utf-8 -*-
require 'resque/tasks'

task "resque:setup" => :environment do
  ENV['QUEUE'] = '*' if ENV['QUEUE'].blank?

  require 'resque'
  Resque::Worker.all.each {|w| w.unregister_worker}

  # Fix for handling resque jobs on Heroku cedar
  # http://stackoverflow.com/questions/2611747/rails-resque-workers-fail-with-pgerror-server-closed-the-connection-unexpectedly
  Resque.after_fork do |job|
    ActiveRecord::Base.establish_connection
  end
end

desc "EC2 instance name changes every time, so run this before a new deployment"
task "resque:clean_workers" => :environment do
  Resque::Worker.all.each {|w| w.unregister_worker}
end

desc "Forcefully restart workers (use upstart to respawn)"
task "resque:restart_workers" => :environment do
  pids = Resque.workers.map { |worker| worker.to_s.split(/:/).second }
  system("kill -QUIT #{pids.join(' ')}") if pids.size > 0
end

desc "Print resque workers pids"
task "resque:pids" => :environment do
  pids = Resque.workers.map { |worker| worker.to_s.split(/:/).second }
  puts pids.join(' ')
end
