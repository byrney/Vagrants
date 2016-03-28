
execute "tz-refresh" do
    command "dpkg-reconfigure -f noninteractive tzdata"
    action :nothing
end
file "/etc/timezone" do
    content "Europe/London\n"
    action  :create
    notifies :run, 'execute[tz-refresh]', :immediate
end
execute "apt-update" do
    creates '/tmp/apt-update.done'
    command "apt-get update > /tmp/apt-update.done"
end
BASE_PACKAGES = %w(git vim tmux zip silversearcher-ag )
APP_PACKAGES  = %w(xorg openbox tint2)

BASE_PACKAGES.each {|p| package p }
APP_PACKAGES.each  {|p| package p }

file "/etc/xdg/openbox/autostart" do
    content "tint2 &\n"
    action  :create
end

