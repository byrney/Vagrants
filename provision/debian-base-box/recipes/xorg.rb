
APP_PACKAGES  = %w(xorg openbox tint2)
APP_PACKAGES.each  {|p| package p }

file "/etc/xdg/openbox/autostart" do
    content "tint2 &\n"
    action  :create
end

