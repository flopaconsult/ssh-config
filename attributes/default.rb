default['ssh_config']['data_bag'] = 'ssh'
default['ssh_config']['data_bag_item'] = 'id_rsa'
default['ssh_config']['ssh_file'] = 'id_rsa'

if (platform?("ubuntu") && node.platform_version.to_f >= 10.04)
  default['ssh_config']['ssh_user'] = 'ubuntu'
else
  default['ssh_config']['ssh_user'] = 'root'
end
default['ssh_config']['ssh_host'] = '*'
