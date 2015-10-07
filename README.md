# Mise-En-Place

Simple provisioning script for CentOS Servers using Capistrano and Chef.

## Dependencies/Assumptions

1. You have Ruby 2.x.x installed
2. You use Chef Client to provision servers (and not Chef Server)
3. Your Chef solution is in a git repo

## Important For Mac Users or If You Are Using SSH Forwarding

On Mac, Capistrano appears to *NOT* use the server's ssh key when trying to perform a git pull from Github/Bitbucket.

To ensure that the git pull of the chef repository works, add your Mac's ssh key (`~/.ssh/id_rsa.pub`) to the Chef repo's deployment keys.


## Safety Flag

When the chef runlist is completed, mise-en-place writes a file to the server: `~/provision.log`

The contents of this log file are the tag used for the chef repo clone.

Before running the `provision` task, mise-en-place checks if this file exists on the server. If it does detect it,
an error will be thrown blocking the provision from occurring.

To force a re-run (*think carefully* if you want to do that, your chef project may clobber existing data), 
simply delete the `~/provision.log` file from the server and 
retry the `provision` task.


## Getting Started

1. Pull this repo
2. `bundle install`
3. Create a `config.yml` file. You can use the `config.yml.sample` as a template
4. Create a `secrets` folder. Within `secrets`, create a `chef` folder
5. Put your `test.json`, `staging.json` and `production.json` files for chef into `secrets/chef`
6. `cap {environment_name} provision` to do a full provision of the server.
7. After the provision has been deemed successful, `cap chef:wipe` to avoid leaving any secrets behind.


## Conventions

Assumptions about environments

* `development` is the active development environment on a developer machine
* `test` is a vagrant vm that is run locally on a developer machine
* `staging` is an mirror of production
* `production` is.. well, production

## Provisioning Tasks


### "One Step"

`cap {environment} provision` or `cap {environment} provision_with_ssh` 

Runs `[ "flag:check", "dependencies:all", "ssh:fingerprints", "chef:clone", "chef:secrets", "chef:run", "flag:write" ]`

`..with_ssh` runs `[ "ssh:authorize", "flag:check", "dependencies:all", "ssh:fingerprints", "chef:clone", "chef:secrets", "chef:run" , "flag:write"]`


See the sections below for what all of the tasks do.




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

`cap {environment} chef:secrets`

Copies `secrets/chef/{environment}.json` to `/var/chef/{environment}.json` on the server.

`cap {environment} chef:pull`

Clones the chef repo in the `config.yml` file.

`cap {environment} chef:run`

Runs the chef-client command.

`cap {environment} chef:update`

Runs `chef:clone` and `chef:run`

`cap {environment} chef:wipe`

Wipes out the `/var/chef` folder on the remote server.

### Flag

`cap {environment} flag:check`

Checks for the existence of `~/provision.log` on the server. If it is there, it throws an error. 

This prevents Chef from being re-run accidentally in a destructive fashion using `mise-en-place`. To force a re-run, remove `~/provision.log`


`cap {environment} flag:write`

Creates a `~/provision.log` file to prevent re-running Chef (using `mise-en-place`)

## Configuration

* Dependencies.yml has some sensible defaults, but can be edited to suit



## Conventions

* Your chef solution is stored in a git based repo.
* 