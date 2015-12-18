require 'rubygems'
require 'websocket-client-simple'

puts "Testing socket"
ws = WebSocket::Client::Simple.connect 'ws://localhost:9000/websocket'

ws.on :message do |msg|
  puts msg.data
end

ws.on :open do
  ws.send('["new_message", {"data":"This is a test"}]')
end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|
  p e
end

loop do
  ws.send('["new_message", {"data":"This is a test"}]')
end
