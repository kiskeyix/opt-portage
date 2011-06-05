#!/bin/sh
# $Revision: 0.1 $
# $Date: Luis Mondesi <lemsx1@gmail.com> $ 
# Luis Mondesi <lemsx1@gmail.com>
#
# DESCRIPTION: Use this to setup ruby into /opt/ruby/$VERSION/bin/ruby
# USAGE: $0
# LICENSE: GPL

PACKAGE=ruby-1.9-stable.tar.gz
RUBY=http://ftp.ruby-lang.org/pub/ruby/$PACKAGE

mkdir ../build ../cache

wget -c $RUBY -O ../cache/$PACKAGE

cd ../build
tar xzf ../cache/$PACKAGE
cd ruby-1.9.*
./configure --prefix=/opt/ruby/1.9
make
make install
make install-doc

echo "You might want to run the following commands:"
echo
echo "sudo ln -s /opt/ruby/1.9/bin/* /usr/bin/"
