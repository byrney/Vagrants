#
# Cookbook Name:: winbase
# Recipe:: default
#
# Copyright 2015, TPWC Ltd
#
# All rights reserved - Do Not Redistribute
#

#node['chocolatey']['upgrade'] = false

include_recipe "chocolatey"

# This causes high cpu when running MSIs
windows_task '\Microsoft\Windows\Application Experience\ProgramDataUpdater' do
      action :disable
end

# disable windows key for LHS of keyboard so it can be used
# as virtualbox key
registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout' do
    values [{:name => 'Scancode Map', :type => :binary, :data => "\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00[\xE0\x00\x00\x00\x00" }]
end

# 7zip 15.14
# 7zip.commandline 15.14
# 7zip.install 15.14
# chocolatey 0.9.9.11
# cmdermini.portable 1.1.4.101
# git.install 2.7.2
# NuGet.CommandLine 3.3.0
# ruby 2.1.6
# ruby2.devkit 4.7.2.2013022402
# sysinternals 2016.02.02
# toolsroot 0.1.0
# vcredist2010 10.0.40219.1
# vim 7.4.1525
# VisualStudio2015Community 14.0.24720.01

## remove vim and cmdermini as blocked by AV
%w{ toolsroot 7zip }.each do |pack|
      chocolatey pack
end

chocolatey 'git.install' do
    options ({ 'params' => "'/GitAndUnixToolsOnPath'" })
    version '2.7.2'
end

windows_shortcut 'c:/Users/Public/Desktop/GVim.lnk' do
  pf = ENV['ProgramFiles(x86)'] || ENV['ProgramFiles']
  vb = '\vim\vim74\gvim.exe'
  target pf + vb
  description "GVim 7.4"
end

windows_shortcut 'c:/Users/Public/Desktop/Cmder.lnk' do
  vb = 'c:\tools\cmdermini\Cmder.exe'
  target vb
  description "Cmder"
end

# start-process -wait -verb runas -argumentlist "ruby -version 2.1.6" cinst
chocolatey 'ruby' do
    action :install
    version '2.3'
end

# ruby2.devkit 4.7.2.2013022402
chocolatey 'ruby2.devkit' do
     action :install
     version '4.7.2.2013022402'
end

