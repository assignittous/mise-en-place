require 'logger'
log = Logger.new(STDERR)




require 'yaml'

dependencies = YAML::load(File.open('dependencies.yml'))

config = YAML::load(File.open('config.yml'))
servers = config['servers']
chef_repo = config['chef']


namespace :chef do





  desc "Clone git repos defined in config.yml"
  task :clone do
    on roles(:app) do
      execute "sudo mkdir -p /var/chef"
      execute "sudo chmod ugo+rw /var/chef"
      # don't sudo the git
      execute "git clone #{chef_repo} /var/chef"


    end
  end

  task :pull do
    on roles(:app) do
      within('/var/chef') do
        execute :git, :pull       
      end     
    end
  end


  desc "Run chef"
  task :run do
    on roles(:app) do
      within('/var/chef') do
        execute "sudo chef-client --local-mode -c /var/chef/solo.rb"         
      end      
    end
  end

  task :update => [ "pull", "run" ]

end