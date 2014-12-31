require 'serverspec'
require 'json'

set :backend, :exec

describe "A Samba4 Active Directory server" do
  before :all do
    n = JSON.parse IO.read('/tmp/kitchen/node.json')
    @node = n['default'].merge n['override']
    puts @node
  end

  it "has samba4 package installed" do
    smb = package('samba')
    expect(smb).to be_installed
    expect(smb.version).to be >= '4'
  end

  %w(netlogon sysvol).each do |share|
    it "has #{share} share enabled" do
      cmd = command %Q{smbclient '\\\\localhost\\#{share}' -Uadministrator -P#{@node['samba4-ad']['adminpass']} -c ls}
      expect(cmd.exit_status).to eq(0)
    end
  end

  it "has dns records set up" do
    commands = ["host -t SRV _ldap._tcp.#{@node['samba4-ad']['domain']}",
                "host -t SRV _kerberos._udp.#{@node['samba4-ad']['domain']}",
                "host -t A #{@node['samba4-ad']['domain']}"]

    commands.map { |c| command c }.each do |cmd|
      expect(cmd.exit_status).to eq(0)
    end
  end
end
