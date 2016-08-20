#
# Cookbook Name:: winbase
# Recipe:: init
#
# Copyright 2015, TPWC Ltd
#
# All rights reserved - Do Not Redistribute
#

#node['chocolatey']['upgrade'] = false

# This causes high cpu when running MSIs
windows_task '\Microsoft\Windows\Application Experience\ProgramDataUpdater' do
      action :disable
end

# disable windows key for LHS of keyboard so it can be used
# as virtualbox key
registry_key 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layout' do
    values [{:name => 'Scancode Map', :type => :binary, :data => "\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00[\xE0\x00\x00\x00\x00" }]
end
