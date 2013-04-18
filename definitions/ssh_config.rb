define(:ssh_config,
  :user      => nil,
  :user_home => nil,
  :ssh_file  => nil,    #node['ssh_config']['ssh_file']
  :ssh_user  => nil,    #node['ssh_config']['ssh_user']
  :ssh_host  => nil,    #node['ssh_config']['ssh_host']
  :data_bag_item => nil #node['ssh_config']['data_bag_item']
  ) do

  user = params[:user]
  user_home = params[:user_home]
  ssh_file = params[:ssh_file]
  ssh_user = params[:ssh_user]
  ssh_host = params[:ssh_host]
  data_bag_item = params[:data_bag_item]

  # set parameters with default values (unfortunally this is not possible in the definition itself...)
  ssh_file = node['ssh_config']['ssh_file'] unless ssh_file
  ssh_user = node['ssh_config']['ssh_user'] unless ssh_user
  ssh_host = node['ssh_config']['ssh_host'] unless ssh_host
  data_bag_item = node['ssh_config']['data_bag_item'] unless data_bag_item

  error = false
  if user == nil
    Chef::Log.fatal("ssh_config: Missing attribute 'user'.")
    error = true
  end
  if user_home == nil
    Chef::Log.fatal("ssh_config: Missing attribute 'user_home'.")
    error = true
  end
  if error
    raise
  end

  directory "#{user_home}/.ssh" do
    owner user
    group user
    mode "0700"
    action :create
  end

  begin
    ssh = data_bag_item(node['ssh_config']['data_bag'], data_bag_item)
  rescue
    Chef::Log.fatal("Could not find the '#{data_bag_item}' item in the '#{node['ssh_config']['data_bag']}' data bag")
    raise
  end

  file "#{user_home}/.ssh/#{ssh_file}" do
    action :create
    owner user
    group user
    mode "0600"
    content ssh['ssh_key']
  end

  template "#{user_home}/.ssh/config" do
    source "config.erb"
    cookbook "ssh-config"
    owner user
    group user
    mode "0600"
    variables(
      :ssh_user => ssh_user,
      :ssh_host => ssh_host,
      :identity_file => ssh_file
    )
  end
end
