package 'samba-client'

ruby_block "Dump node attributes" do
  block do
    IO.write '/tmp/kitchen/node.json', node.to_json
  end
end
