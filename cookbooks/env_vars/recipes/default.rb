#
# Cookbook Name:: env_vars
# Recipe:: default
#

if ['solo', 'app', 'app_master', 'util'].include?(node.dna.instance_role)

  execute "reload-nginx" do
    action :nothing
    command "/etc/init.d/nginx reload"
  end
  
  node['dna']['applications'].each do |app_name, data|
    template "/data/#{app_name}/shared/config/env.custom" do
      source "env.custom.erb"
      owner node['dna']['users'].first['username']
      group node['dna']['users'].first['username']
      mode 0744
      variables({
          :env_vars => node['env_vars']
      })
    end
    
    case node['dna']['engineyard']['environment']['stack']
    when /nginx_passenger/i
      template "/data/#{app_name}/shared/bin/ruby_wrapper" do
        not_if {(node.engineyard.environment.stack =~ /nginx_passenger/i).nil?}

        source "ruby_wrapper.erb"
        owner node['dna']['users'].first['username']
        group node['dna']['users'].first['username']
        mode 0755
        variables({
            :app_name => app_name
        })
      end
            
      execute "update-nginx-passenger-ruby" do
        not_if {(node.engineyard.environment.stack =~ /nginx_passenger/i).nil?}
        not_if "grep passenger_ruby /etc/nginx/stack.conf"

        command "echo 'passenger_ruby /data/#{app_name}/shared/bin/ruby_wrapper;' >> /etc/nginx/stack.conf"
        notifies :run, 'execute[reload-nginx]'
      end
    end
  end
end
