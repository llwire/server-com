require 'faye/websocket'
require 'eventmachine'

EM.run {
  ws = Faye::WebSocket::Client.new('ws://localhost:9000/websocket')

  ws.on :open do |event|
    p [:open]
    ws.send('["new_message", {"id":1213, "data":"This is a test"}]')
  end

  ws.on :message do |event|
    p [:message, event.data]
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}
