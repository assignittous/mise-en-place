require 'logger'
log = Logger.new(STDERR)


require 'yaml'
servers = YAML::load(File.open('servers.yml'))



namespace :server do
  task :provision do
    log.info "starting"
    run "pwd"
  end

end
