#!/bin/bash

set -e
set -u

# Dependenncies
for pkg in postgresql-server-dev-9.4 postgresql-contrib-9.4 python python-pip python-dev ; do
    dpkg-query -l "$pkg" 2> /dev/null | grep -qE '^ii' || apt-get install -y "$pkg"
done

# postgres config
conf="/etc/postgresql/9.4/main/postgresql.conf"
grep -q powa.frequency "$conf" || cat << EOF >> "$conf"
    shared_preload_libraries='pg_stat_statements,powa,pg_stat_kcache,pg_qualstats'
    powa.frequency = '5s'
EOF

#powa archivist extension
powa_file=REL_2_0_0.tar.gz
powa_dir="powa-archivist-REL_2_0_0" 
if [[ ! -d "$powa_dir" ]] ; then
    mkdir -p "$HOME/Downloads"
    cd "$HOME/Downloads"
    wget --quiet "https://github.com/dalibo/powa-archivist/archive/$powa_file"
    tar xfz "$powa_file"
    cd "$powa_dir/"
    ./install_all.sh
    systemctl restart postgresql
    psql -d postgres -f install_all.sql
fi


# web server
pip install powa-web

cat << EOF > /etc/powa-web.conf
servers={
  'main': {
    'host': 'localhost',
    'port': '5432',
    'database': 'powa'
  }
}
cookie_secret="12345612342346797543"
EOF

