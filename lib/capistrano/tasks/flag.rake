require 'logger'
log = Logger.new(STDERR)



namespace :flag do


  task :write do
    env = fetch(:stage).to_s
    
    on roles(:app) do
      execute "touch ~/provision.log"
      execute "echo 'Chef Repo #{chef[env]['tag']}' > ~/provision.log"
      #execute "sudo gem install bundler"
    end

  end


  task :check do
    on roles(:all) do
      if test("[ -f ~/provision.log ]")
        # the file exists
        log.error "This server was provisioned!"
        raise "This server has a ~/provision.log which means chef was previously run"
      else
        # the file does not exist
        log.info "This appears to be a clean server"
      end
    end
  end

end