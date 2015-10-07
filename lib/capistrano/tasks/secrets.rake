require 'logger'
log = Logger.new(STDERR)


require 'yaml'

dependencies = YAML::load(File.open('dependencies.yml'))

config = YAML::load(File.open('config.yml'))
postgresql = config['postgresql']

fingerprints = config['fingerprints']


namespace :secrets do

# . /etc/profile

  task :write do
    env = fetch(:stage).to_s


    file = "secrets/chef/#{env}.json"
    on roles(:app) do 
      #secrets = postgresql[env]

      #secrets.keys.each do |secret|
        #output = "#{secret}=\"#{secrets[secret]}\""
        #execute "sudo sh -c \"echo '#{output}' >> /etc/environment\""
      #end
      upload! file, "#{env}.sh"
      # etc/profile.d/
      #execute "sudo chmod ugo+rwx ~/#{env}.sh"
      execute "sudo mv -f ~/#{env}.sh /etc/profile.d"


    end
  end

  task :test do
    #file = "secrets/#{env}.sh"
    on roles(:app) do 
      execute "echo $PG_POSTGRES"

      
      
      #upload! file, "#{env}.sh"
      # etc/profile.d/
      #execute "sudo chmod ugo+rwx ~/#{env}.sh"
      # execute "sudo mv -f ~/#{env}.sh /etc/profile.d"
    end
  end
end