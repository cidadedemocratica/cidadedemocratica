require "bundler/capistrano"
set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}
set :bundle_flags, "--deployment --quiet --binstubs"

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "cidadedemocratica"
set :user, "cidadedemocratica"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "https://github.com/cidadedemocratica/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  task :start do; end
  task :stop do; end
  task :ativar_manutencao, :roles => :app, :except => { :no_release => true } do
    run "touch #{deploy_to}/current/tmp/manutencao.txt"
  end
  task :desativar_manutencao, :roles => :app, :except => { :no_release => true } do
    run "rm #{deploy_to}/current/tmp/manutencao.txt"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{deploy_to}/current/tmp/restart.txt"
  end

  task :setup_config, :roles => :app do
    # sudo "ln -nfs #{current_path}/config/apache.conf /etc/apache2/sites-available/#{application}"
    run "mkdir -p #{shared_path}/config"
    run "mkdir -p #{shared_path}/uploaded"
    run "mkdir -p #{shared_path}/apache"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    put File.read("config/oauth.example.yml"), "#{shared_path}/config/oauth.yml"
    put File.read("config/.htaccess"), "#{shared_path}/apache/.htaccess"
    put File.read("config/email.example.yml"), "#{shared_path}/config/email.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/oauth.yml #{release_path}/config/oauth.yml"
    run "rm -rf #{release_path}/public/images/uploaded"
    run "ln -nfs #{shared_path}/uploaded #{release_path}/public/images/uploaded"
    run "ln -nfs #{shared_path}/apache/.htaccess #{release_path}/public/.htaccess"
    run "ln -nfs #{shared_path}/config/email.yml #{release_path}/config/email.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, :roles => :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/#{branch}`
      puts "WARNING: HEAD is not the same as origin/#{branch}"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end
