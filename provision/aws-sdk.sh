#!/bin/bash


for pkg in 'ruby-nokogiri' ; do
	dpkg-query -l $pkg &> /dev/null || apt-get install -y $pkg
done

for gem in 'aws-sdk' ; do
	gem which "$gem" &> /dev/null || gem install "$gem"
done


