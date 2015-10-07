require 'logger'
log = Logger.new(STDERR)




require 'yaml'

dependencies = YAML::load(File.open('dependencies.yml'))

config = YAML::load(File.open('config.yml'))
servers = config['servers']
chef = config['chef']


namespace :chef do

  
  desc "Remove /var/chef"
  task :wipe do
    env = fetch(:stage).to_s
    on roles(:app) do
      execute "sudo rm -r -f /var/chef"

    end
  end



  desc "Clone git repos defined in config.yml"
  task :clone do
    env = fetch(:stage).to_s
    on roles(:app) do

      execute "sudo mkdir -p /var/chef"
      execute "sudo chmod ugo+rw /var/chef"
      # don't sudo the git
      #execute "git clone #{chef_repo} /var/chef"
      execute "git clone -b #{chef[env]['tag']} --depth 1 #{chef[env]['repo']} /var/chef"

    end
  end

  task :pull do
    on roles(:app) do
      within('/var/chef') do
        execute :git, :clone       
      end     
    end
  end

  task :secrets do
    env = fetch(:stage).to_s
    file = "secrets/chef/#{env}.json"
    on roles(:app) do 
      upload! file, "#{env}.json"
      execute "sudo mv -f ~/#{env}.json /var/chef"
    end
  end


  desc "Run chef"
  task :run do
    env = fetch(:stage).to_s
    

    if ['test', 'staging', 'production'].include? env

      on roles(:app) do
        within('/var/chef') do
          execute "sudo chef-client --local-mode -c /var/chef/client.rb -j /var/chef/#{env}.json --logfile ~/chef.log"     
          #  --log_level debug    
        end      
      end
    else
      log.error "Chef was not run. The environment #{env} is not one of 'test', 'staging' or 'production'"
    end

  end

  # sudo chef-client --override-runlist "recipe[mycookbook::recipe]” --local-mode -c /var/chef/client.rb`


  task :update => [ "wipe", "clone", "secrets", "run" ]
  task :install => [ "wipe", "clone", "secrets", "run" ]

end
