
package %W(curl openssh-server ca-certificates postfix)

remote_file '/home/vagrant/gitlab-install.sh' do
    source 'https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh'
    notifies :run, 'execute[installer]', :immediate
    action :create
end

remote_file '/home/vagrant/gitlab-runner.sh' do
    source 'https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.deb.sh'
    notifies :run, 'execute[runner]', :immediate
    action :create
end


execute 'installer' do
    command 'bash /home/vagrant/gitlab-install.sh'
    action :nothing
end

execute 'runner' do
    command 'bash /home/vagrant/gitlab-runner.sh'
    action :nothing
end

package 'gitlab-ce'

package 'gitlab-ci-multi-runner'

package %W(ruby2.3 binutils ruby2.3-dev)
