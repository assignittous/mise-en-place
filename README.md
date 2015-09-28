# Mise-En-Place

Simple provisioning script for CentOS Servers using Capistrano and Chef.

## Dependencies/Assumptions

1. You have Ruby 2.x.x installed
2. You use Chef to provision servers
3. Your Chef is in a git repo




## Getting Started

1. Pull this repo
2. `bundle install`
3. Create a `servers.yml` file. You can use the `servers.yml.sample` as a template
4. `cap {environment_name} provision:complete` to do a full provision of the server.

## Provisioning Tasks




## Configuration

* Dependencies.yml has some sensible defaults, but can be edited to suit



## Conventions

* Your chef solution is stored in a git based repo.
* 