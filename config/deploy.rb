require 'pathname'

require 'logger'

log = Logger.new(STDERR)




# config valid only for current version of Capistrano

lock '3.4.0'

set :application, 'pifm-centos'
#set :repo_url, 'https://github.com/assignittous/pifm-centos.git'


# https://github.com/assignittous/pifm-centos.git
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5



namespace :deploy do


  task :starting do

    log.error "I think you meant cap #{fetch(:stage)} provision"
    raise "deploy is disabled for this project"
  end


  task :started do

  end

  task :updating do

  end

  task :updated do

  end

  task :publishing do

  end

  task :published do

  end

  task :reverting do

  end

  task :reverted do

  end



  task :finishing do

  end

  task :finishing_rollback do

  end

  task :finished do
    log.info "Postflight"
  end


  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

task :reboot do
  on roles(:app) do
    execute "sudo systemctl reboot"
  end
end


task :provision  => [ "flag:check", "dependencies:all", "ssh:fingerprints", "chef:clone", "chef:secrets", "chef:run", "flag:write" ]

task :provision_with_ssh  => [ "ssh:authorize", "flag:check", "dependencies:all", "ssh:fingerprints", "chef:clone", "chef:secrets", "chef:run" , "flag:write"]