require 'logger'
log = Logger.new(STDERR)

require 'yaml'

dependencies = YAML::load(File.open('dependencies.yml'))

config = YAML::load(File.open('config.yml'))
servers = config['servers']
chef_repo = config['chef']

fingerprints = config['fingerprints']

task :environment do


  puts fetch(:stage)

end


task :git_test do
    on roles(:app) do
      execute "ssh -v git@bitbucket.org"
    end


end

task :diagnostic do


    on roles(:app) do
      ssh_account = config['ssh_account']
      # execute "ssh-keygen -t rsa -f ~/.ssh/id_rsa.pub -C \"#{ssh_account}\" -N \"\""

      log.info "===========================================================START DIAGNOSTIC"
      log.info "===========================================================Kernel"
      execute "uname -r"
      log.info "===========================================================Network"
      execute "sudo ip a sh"
      log.info "===========================================================Path"
      execute "echo $PATH"
      log.info "===========================================================SUDO Path"
      execute "sudo echo $PATH"            
      log.info "===========================================================Ruby Version"
      execute "ruby -v"            
      log.info "===========================================================Gem List"
      execute "gem list"        
      log.info "===========================================================Gem Environment"
      execute "gem environment"        

      log.info "===========================================================Var Directory"
    
        execute "sudo ls -l -a /var"

      log.info "===========================================================Chef Directory"
    
        execute "sudo ls -l -a /var/chef"


      log.info "===========================================================SSH directory"

        execute "ls ~/.ssh"
        begin

          log.info "===========================================================authorized_keys"
          execute "sudo cat ~/.ssh/authorized_keys"     
        rescue
          log.error "authorized_keys does not exist in ~/.ssh"
        end

        begin

          log.info "===========================================================id_rsa.pub"
          execute "sudo cat ~/.ssh/id_rsa.pub"     
        rescue
          log.error "id_rsa.pub does not exist in ~/.ssh"
        end

        begin

          log.info "===========================================================known_hosts"
          execute "sudo cat ~/.ssh/known_hosts"     
        rescue
          log.error "known_hosts does not exist in ~/.ssh"
        end        
  
        log.info "===========================================================END DIAGNOSTIC"

      execute "sudo echo \"Test Successful\""
    end


end