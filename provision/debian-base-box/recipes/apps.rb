
case node['platform_family']
when 'debian'
    BASE_PACKAGES = %w(git vim tmux zip silversearcher-ag rake )
when 'rhel'
    BASE_PACKAGES = %w(git vim tmux zip )
end

BASE_PACKAGES.each {|p| package p }

