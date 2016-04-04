
DEV_PACKAGES  = %w(git-sh git-svn ruby-build ruby-full bundler node npm)
DEV_PACKAGES.each  {|p| package p }

link '/usr/bin/node' do
    to '/usr/bin/nodejs'
end

# package 'postgresql-9.4'
# package 'postgresql-client-9.4'
# execute "postgresql-users" do
#     command 'createuser -s vagrant || echo "vagrant user already in postgres" '
#     user "postgres"
#     action :run
# end
include_recipe "#{cookbook_name}::postgres"
