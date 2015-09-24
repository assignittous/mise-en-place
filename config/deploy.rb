require 'pathname'

require 'logger'

log = Logger.new(STDERR)


require 'yaml'
servers = YAML::load(File.open('servers.yml'))
dependencies = YAML::load(File.open('dependencies.yml'))


# config valid only for current version of Capistrano

lock '3.4.0'

set :application, 'pifm-centos'
#set :repo_url, 'https://github.com/assignittous/pifm-centos.git'


# https://github.com/assignittous/pifm-centos.git
# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5


namespace :provision do

  desc "Provision a server that already has ssh installed"
  task :complete do

    sysprep
    yum
    tarballs
    rpm
    git_clones
    chef_client

  end


  task :test do
    log.info "test"
    on roles(:app) do
      execute "pwd"
    end
  end

  # add ssh key to prevent future password prompts
  desc "Add ssh public key to server's authorized keys"
  task :authorize_ssh_key do
    file = File.open("#{File.expand_path('~')}/.ssh/id_rsa.pub", "rb")
    public_key = file.read
    on roles(:app, :web, :db) do
      execute "echo \"#{public_key}\n\" >> ~/.ssh/authorized_keys"
    end
  end


  desc "Create /sysprep on server"
  task :sysprep do

    on roles(:app) do
      
      execute "sudo rm -r /sysprep -r -f"
      execute "sudo mkdir /sysprep -p"

    end
  end

  desc "Install yum packages defined in dependencies.yml"
  task :yum do
    on roles(:app) do
      groups = dependencies['yum']['groups'].collect { |g| "\"#{g}\""}
      execute "sudo yum groupinstall #{groups.join(' ')} -y"

      packages = dependencies['yum']['packages'].collect { |g| "\"#{g}\""}
      execute "sudo yum install #{packages.join(' ')} -y"
    end
  end

  desc "Install tarballs via wget defined in dependencies.yml"
  task :tarballs do
    on roles(:app) do
      tarballs = dependencies['tarballs']
      tarballs.each do |tarball|


        filename = Pathname.new(tarball).basename
        folder = filename.sub('.tar.gz','') 


        within('/sysprep') do
          
          execute "sudo wget #{tarball} -o /sysprep/#{filename}"         
          execute "sudo tar xzf #{filename} -C /sysprep"


        end          

        within("/sysprep/#{folder}") do
          execute "sudo /sysprep/#{folder}/configure" # --prefix=/usr/local"
          execute "sudo make"
          execute "sudo make install"
        end
      end
      
    end
  end

  desc "Install rpms defined in dependencies.yml"
  task :rpm do
    packages = dependencies['rpm']
    packages.each do |package|
      execute "rpm i #{package} "
    end


  end

  desc "Clone git repos defined in dependencies.yml"
  task :git_clones do
    on roles(:app) do

      #execute 'sudo git clone https://github.com/assignittous/pifm-centos.git /sysprep/pifm'


    end
  end

  desc "Run chef"
  task :chef_client do

  end

end



namespace :deploy do



  task :starting do
    log.info "Preflight-------------------"
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
