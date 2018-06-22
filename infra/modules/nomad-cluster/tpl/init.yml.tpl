#cloud-config
repo_update: true
repo_upgrade: all
package_upgrade: true
packages:
 - nc
 - telnet
 - docker.io
groups:
 - docker: [ubuntu]
runcmd:
 - sudo service docker start
