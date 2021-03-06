require 'logger'
log = Logger.new(STDERR)


require 'yaml'

dependencies = YAML::load(File.open('dependencies.yml'))

config = YAML::load(File.open('config.yml'))
servers = config['servers']
chef_repo = config['chef']

fingerprints = config['fingerprints']

namespace :ssh do

  task :test do
    on roles(:app) do
      ssh_account = config['ssh_account']
      # execute "ssh-keygen -t rsa -f ~/.ssh/id_rsa.pub -C \"#{ssh_account}\" -N \"\""
      execute "sudo echo \"Test Successful\""
    end
  end

  task :sudofix do
    # makes the path for sudo same as normal user
    on roles(:app) do

        execute "sudo echo 'alias sudo=\"sudo env PATH=$PATH\"' >> ~/.bashrc"



    end
  end

  task :fingerprints do

    on roles(:app) do

      fingerprints.each do |fingerprint|
        # these will fail when known_hosts doesn't exist
        #execute "ssh-keygen -R #{fingerprint['hostname']}"
        #execute "ssh-keygen -R #{fingerprint['ip']}"
        #execute "ssh-keygen -R #{fingerprint['hostname']},#{fingerprint['ip']}"
        execute "ssh-keyscan -H -t rsa,dsa #{fingerprint['hostname']},#{fingerprint['ip']} >> ~/.ssh/known_hosts"
        execute "ssh-keyscan -H -t rsa,dsa #{fingerprint['ip']} >> ~/.ssh/known_hosts"
        execute "ssh-keyscan -H -t rsa,dsa #{fingerprint['hostname']} >> ~/.ssh/known_hosts"
      end


    end
  end  

  desc "Add ssh public key to server's authorized keys"
  task :authorize do
    file = File.open("#{File.expand_path('~')}/.ssh/id_rsa.pub", "rb")
    public_key = file.read
    on roles(:app, :web, :db) do
      execute "echo \"#{public_key}\n\" >> ~/.ssh/authorized_keys"
    end
  end

  task :keygen do
    on roles(:app) do
      ssh_account = config['ssh_account']
      execute "ssh-keygen -t rsa -f ~/.ssh/id_rsa -C \"#{ssh_account}\" -N \"\""
      execute "cat ~/.ssh/id_rsa.pub"
    end
  end

end