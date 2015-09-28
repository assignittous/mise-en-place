require 'logger'
log = Logger.new(STDERR)


require 'yaml'
servers = YAML::load(File.open('servers.yml'))
dependencies = YAML::load(File.open('dependencies.yml'))
repos = YAML::load(File.open('repos.yml'))
config = YAML::load(File.open('config.yml'))

namespace :provision do

  # get the email below from a .gitignore'd file
  # ssh-keygen -t rsa -C "email@email.com"

  #todo - make the /var/www dir -- validate that this is not chef
  #todo - set the permissions of the /var/www dir

  #todo - get the ssh-key for adding to git repo deploy keys

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

  task :ssh_prep do
    on roles(:app) do
      ssh_account = config['ssh_account']
      # execute "ssh-keygen -t rsa -f ~/.ssh/id_rsa.pub -C \"#{ssh_account}\" -N \"\""
      execute "cat ~/.ssh/id_rsa.pub"
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
    on roles(:app) do
      packages.each do |package|
        execute "sudo rpm -i #{package} "
      end
    end


  end

  desc "Clone git repos defined in repos.yml"
  task :git_clones do
    on roles(:app) do
      chef_repo = repos['chef']
      execute "sudo mkdir /var/chef"
      execute "sudo chmod ugo+rw /var/chef"
      # don't sudo the git
      execute "git clone #{chef_repo} /var/chef"


    end
  end

  desc "Run chef"
  task :chef_client do
    on roles(:app) do
      within('/var/chef') do
        
        execute "sudo chef-client --local-mode -c /var/chef/solo.rb"         



      end      
    end
  end
  desc "Provision a server that already has ssh installed"
  task :complete  => [ :sysprep ,:yum ,:tarballs ,:rpm ,:git_clones ,:chef_client ]


end

