require 'rubygems'
require 'websocket-client-simple'

puts "Testing socket"
ws = WebSocket::Client::Simple.connect 'ws://localhost:9000/client/remote'

ws.on :message do |msg|
  puts msg.data
end

ws.on :open do
  ws.send('{"id": "kd;faklsjfa", "data":"This is a test"}')
end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|
  p e
end

count = 0

loop do
  ws.send('["new_message", {"data":"This is a test"}]')
  ws.on :message do |msg|
    count += 1
    puts "count = #{count}"
    puts msg.data
  end
  sleep 30
end
