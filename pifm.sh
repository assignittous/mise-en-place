#!/bin/bash
if [ $# -lt 2 ]
  then
    echo "Two arguments are required - environment and git repo url"
    echo "Example:"
    echo "test.sh prod https://username@gitserver.org/reponame/chef.git"
  else
    # Create temp folder for install files
    mkdir /sysprep  
    cd /sysprep

    # Dependency installation
    yum install openssl-devel zlib-devel -y  
    yum groupinstall 'Development Tools' -y  
    yum groupinstall development-libs -y  
    yum install readline-devel -y  
    yum install zlib-devel -y  
    yum install openssl-devel -y  
    yum install libffi -y  
    yum install httpd -y  
    yum install httpd-devel -y  
    yum install sqlite-devel -y  
    yum install git -y  
    yum install httpd-devel -y  
    yum install curl-devel -y  
    yum install mod_ssl openssl -y  
    yum install -y gcc ruby-devel libxml2 libxml2-devel libxslt libxslt-devel
    yum install nano -y
    yum install wget -y
    yum update -y
    wget http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz  
    wget ftp://sourceware.org/pub/libffi/libffi-3.0.13.tar.gz 
    wget http://yum.postgresql.org/9.3/redhat/rhel-latest-i386/pgdg-centos93-9.3-1.noarch.rpm
    wget http://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p547.tar.gz  
    tar xzvf ruby-1.9.3-p547.tar.gz  
    tar xzvf yaml-0.1.4.tar.gz  
    tar xzvf libffi-3.0.13.tar.gz

    # compile
    cd /sysprep/libffi-3.0.13
    ./configure --prefix=/usr/local
    make
    make install
    cd /sysprep/yaml-0.1.4
    ./configure --prefix=/usr/local
    make
    make install
    cd /sysprep/ruby-1.9.3-p547
    ./configure --prefix=/usr/local
    make
    make install
    curl -L https://www.opscode.com/chef/install.sh | bash

    # Clone the chef cookbook
    cd /var
    git clone  $2

    # Run chef
    echo "chef-client --local-mode --switch $2.json"

fi