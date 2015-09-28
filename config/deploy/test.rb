

require 'yaml'
config = YAML::load(File.open('config.yml'))
servers = config["servers"]


server servers['test']['address'], user: servers['test']['remote_user'], roles: %w{web app db}
