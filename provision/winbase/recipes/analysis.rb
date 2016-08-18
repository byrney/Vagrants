
include_recipe "chocolatey"

chocolatey 'r.studio' do
    action :install
    version '0.99.903'
end


chocolatey 'python3' do
    action :install
    version '3.5.1'
end


