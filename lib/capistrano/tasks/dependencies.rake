require 'logger'
log = Logger.new(STDERR)


require 'yaml'

dependencies = YAML::load(File.open('dependencies.yml'))

config = YAML::load(File.open('config.yml'))
servers = config['servers']
chef_repo = config['chef']

namespace :dependencies do

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

  desc "Provision a server that already has ssh installed"
  task :all  => [ :sysprep ,:yum ,:tarballs ,:rpm  ]


end

