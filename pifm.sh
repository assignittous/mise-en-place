#!/bin/bash
if [ $# -lt 2 ]
  then
    echo "Two arguments required - Environment and Git Repository URL"
    echo "Example:"
    echo "pifm-centos.sh prod https://username@github.com/reponame/chef.git"
  else
    # Create folder for install files
    echo "mkdir /sysprep"
    echo "cd /sysprep"

    # Dependency installation

    groups=("Development Tools" development-libs)

    for group in "${groups[@]}"; do
      echo "yum groupinstall ${group} -y"
    done



    packages=(zlib-devel openssl-devel libffi httpd httpd-devel sqlite-devel git curl-devel wget nano mod_ssl openssl gcc ruby-devel libxml2 libxml2-devel libxslt libxslt-devel)

    for package in ${packages[@]}; do
      echo "yum install ${package} -y"
    done

    echo "yum update -y"

    # Download and install some libraries

    # assumes .tar.gz
    libraries=(http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz ftp://sourceware.org/pub/libffi/libffi-3.0.13.tar.gz http://ftp.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz  )

    for library in ${libraries[@]}; do
      echo "cd /sysprep"
      echo "wget ${library}"
      #f = $(basename $library)
      filename=${library##*/}
      tarfile=${filename%.*}
      folder=${tarfile%.*}
      echo "tar xzvf ${filename}"
      echo "cd /sysprep/${folder}"
      echo "./configure --prefix=/usr/local"
      echo "make"
      echo "make install"
    done



    #cd /sysprep
    #wget http://yum.postgresql.org/9.3/redhat/rhel-latest-i386/pgdg-centos93-9.3-1.noarch.rpm


    #cd /sysprep    


    # compile

    #curl -L https://www.opscode.com/chef/install.sh | bash

    # Clone the chef cookbook
    #cd /var

    echo "git clone $2"

    # Run chef
    echo "chef-client --local-mode --switch $2.json"

fi