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

%w{ toolsroot sysinternals 7zip vim cmdermini.portable }.each do |pack|
      chocolatey pack
end

chocolatey 'git.install' do
    options ({ 'params' => "'/GitAndUnixToolsOnPath'" })
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

user=node['users']['username']

git "Users/#{user}/Config" do
    repository 'https://github.com/byrney/Config.git'
    notifies :run, 'execute[install-config]', :immediately
end


execute "install-config" do
    u = user
    h = "c:\\Users\\#{u}"
    #creates "#{h}/.vimrc"
    cwd "#{h}\\Config"
    command 'bash install.sh rob.cfg'
    environment 'HOME' => "c:\\Users\\#{u}"
    action :nothing
end

# start-process -wait -verb runas -argumentlist "ruby -version 2.1.6" cinst
chocolatey 'ruby' do
    action :install
    version '2.1.6'
end

#start-process -wait -verb runas -argumentlist "rubygems -version 2.4.6" cinst
# chocolatey 'rubygems' do
#     action :install
#     version '2.4.6'
# end

chocolatey 'ruby2.devkit' do
     action :install
end

