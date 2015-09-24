require 'yaml'
servers = YAML::load(File.open('servers.yml'))

server servers['test']['address'], user: servers['test']['remote_user'], roles: %w{web app db}
