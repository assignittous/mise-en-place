# Mise-En-Place

Simple provisioning script for CentOS Servers using Capistrano and Chef.

## Dependencies/Assumptions

1. You have Ruby 2.x.x installed
2. You use Chef to provision servers
3. Your Chef is in a git repo

## Important For Mac Users or If You Are Using SSH Forwarding

On Mac, Capistrano appears to *NOT* use the server's ssh key when trying to perform a git pull from Github/Bitbucket.

To ensure that the git pull of the chef repository works, add your Mac's ssh key (`~/.ssh/id_rsa.pub`) to the Chef repo's deployment keys.


## Getting Started

1. Pull this repo
2. `bundle install`
3. Create a `config.yml` file. You can use the `config.yml.sample` as a template
4. `cap {environment_name} provision` to do a full provision of the server.

## Provisioning Tasks


### "One Step"

`cap {environment} provision`

Runs `dependencies:all`, `ssh:fingerprints`, `chef:clone`, `chef:run`


### SSH

`cap {environment} ssh:test`

Simple SSH connection test. Echos a string. Useful when testing if the `ssh:authorize` worked.

`cap {environment} ssh:authorize`

Adds your ssh public key to the server's authorized key. Assumes the location is `~/.ssh/id_rsa.pub`

`cap {environment} ssh:fingerprints`

Adds the fingerprints items in `config.yml` to the current server's `known_hosts` file.

### Dependencies

`cap {environment} dependencies:sysprep`

Creates `/sysprep` folder and assigns permissions

`cap {environment} dependencies:yum`

Installs yum packages indicated in `config.yml`

`cap {environment} dependencies:tarballs`

`wget` and install tarballs indicated in `config.yml`


`cap {environment} dependencies:rpm`

Installs rpms indicated in `config.yml`

`cap {environment} dependencies:all`

Runs `dependencies:sysprep`, `dependencies:yum`, `dependencies:tarballs`, `dependencies:rpm` and `dependencies:all`

### Chef

`cap {environment} chef:clone`

Clones the chef repo in the `config.yml` file.

`cap {environment} chef:pull`

Clones the chef repo in the `config.yml` file.

`cap {environment} chef:run`

Runs the chef-client command.

`cap {environment} chef:update`

Runs `chef:pull` and `chef:run`





## Configuration

* Dependencies.yml has some sensible defaults, but can be edited to suit



## Conventions

* Your chef solution is stored in a git based repo.
* 