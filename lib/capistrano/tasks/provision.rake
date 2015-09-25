require 'logger'
log = Logger.new(STDERR)


require 'yaml'
servers = YAML::load(File.open('servers.yml'))



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
    on roles(:app) do
      execute 'pwd'
    end
  end

end

