for pkg in mono-devel monodevelop ; do
	dpkg-query -l $pkg &> /dev/null || apt-get install -y $pkg
done

if [[ ! -f /usr/local/bin/nuget.exe ]] ; then
	mozroots --import --sync --quiet --machine
	curl -s -L http://nuget.org/nuget.exe -o /usr/local/bin/nuget.exe || { echo "Failed to download nuget" ; exit 1; }
fi
mono /usr/local/bin/nuget.exe install microsoft-web-helpers


#
# More up to date mono packages that go into /opt
# source /opt/mono/env.sh to enable
lst=/etc/apt/sources.list.d/mono-opt.list
if [[ ! -f "$lst" ]] ; then
	echo 'deb http://download.opensuse.org/repositories/home:/tpokorra:/mono/Debian_7.0/ /' > "$lst"
	apt-key add - < /vagrant/mono-opt.key
	apt-get update
fi

for pkg in mono-opt monodevelop-opt ; do
	dpkg-query -l $pkg &> /dev/null || apt-get install -y $pkg
done

