require 'logger'
log = Logger.new(STDERR)


require 'yaml'

dependencies = YAML::load(File.open('dependencies.yml'))

config = YAML::load(File.open('config.yml'))
servers = config['servers']
chef = config['chef']

namespace :dependencies do



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
        execute "sudo rpm -i --force #{package} "
      end
    end


  end


  task :flag do
    env = fetch(:stage).to_s
    
    on roles(:app) do
      execute "touch ~/provision.log"
      execute "echo 'Chef Repo #{chef[env]['tag']}' > ~/provision.log"
      #execute "sudo gem install bundler"
    end

  end

  task :ruby do
    on roles(:app) do
      execute "ruby --v"
      #execute "sudo gem install bundler"
    end

  end

  desc "Provision a server that already has ssh installed"
  task :all  => [ :sysprep ,:yum ,:tarballs, :rpm, :flag]


end

