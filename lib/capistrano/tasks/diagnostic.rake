require 'logger'
log = Logger.new(STDERR)


require 'yaml'

dependencies = YAML::load(File.open('dependencies.yml'))

config = YAML::load(File.open('config.yml'))
servers = config['servers']
chef_repo = config['chef']

fingerprints = config['fingerprints']

task :diagnostic do


    on roles(:app) do
      ssh_account = config['ssh_account']
      # execute "ssh-keygen -t rsa -f ~/.ssh/id_rsa.pub -C \"#{ssh_account}\" -N \"\""


      log.info "==========================================================="
      log.info "General info"
      log.info "Kernel"
      execute "uname -r"
      log.info "==========================================================="
      log.info "Network"
      execute "ip a sh"
      log.info "==========================================================="
      log.info "Testing chef directory"
      within('/var/chef') do
        execute "pwd"         
        execute "ls -l -a"
      end      
      log.info "==========================================================="
      within('~/.ssh') do
        log.info "--authorized_keys"
        execute "cat authorized_keys"     
        log.info "--id_rsa.pub"   
        execute "cat id_rsa.pub"
        log.info "--known_hosts"
        execute "cat known_hosts"        
      end    

      execute "sudo echo \"Test Successful\""
    end


end