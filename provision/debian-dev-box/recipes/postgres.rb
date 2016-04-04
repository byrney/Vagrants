
package 'apt-transport-https'
package 'ca-certificates'

#
# Postgres install
#
apt_repository "postgresql" do
  uri "http://apt.postgresql.org/pub/repos/apt/"
  distribution 'jessie-pgdg'
  components ["main"]
  key "https://www.postgresql.org/media/keys/ACCC4CF8.asc"
end

package 'postgresql-9.5'
