require 'faye/websocket'
require 'eventmachine'
require 'json'

EM.run {
  ws = Faye::WebSocket::Client.new('ws://localhost:9000/client/remote')

  msg = {
    jsonrpc: "2.0",
    method: "echo",
    params: {
      x: "test"
    },
    id: "iowirpqiwr"
  }

  ws.on :open do |event|
    p [:open]
    ws.send(msg.to_json)
  end

  ws.on :message do |event|
    p [:message, event.data]
    ws.send(msg.to_json)
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}
