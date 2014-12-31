package 'samba'

file '/etc/samba/smb.conf' do
  action :delete
end

execute 'domain provisioning' do
  command ["samba-tool",
           "domain",
           "provision",
           "--realm=#{node['samba4-ad']['domain']}",
           "--domain=#{node['samba4-ad']['domain'].split(/\./).first}",
           "--dns-backend=SAMBA_INTERNAL",
           "--function-level=2008_R2",
           "--server-role=dc",
           "--use-rfc2307",
           "--use-ntvfs",
           "--adminpass=#{node['samba4-ad']['adminpass']}",
           "--option='dns forwarder = #{node['samba4-ad']['dns-forwarder']}'"].join(' ')
end

%w(smbd nmbd).each do |s|
  service s do
    action [:stop, :disable]
  end
end

service 'samba-ad-dc' do
  action [:start, :enable]
end

file '/etc/resolv.conf' do
  action :delete
end

template '/etc/resolv.conf' do
  source 'resolv.conf.erb'
  variables domain: node['samba4-ad']['domain']
end

# Make resolv.conf immutable so it cannot be overwritten by anything else
execute 'chattr +i /etc/resolv.conf'
