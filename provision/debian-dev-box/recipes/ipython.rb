

package 'apt-transport-https' if node['platform_family'] == 'debian'
package 'ca-certificates'

#
# Install jupyter with python 3
#
#package ['python3', 'python3-pip']
python_runtime '3'

python_package 'jupyter'

