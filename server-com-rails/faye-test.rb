require 'faye/websocket'
require 'eventmachine'
require 'json'

EM.run {
  ws = Faye::WebSocket::Client.new('ws://localhost:9000/client/remote')

  ws.on :open do |event|
    p [:open]
    msg = {
      jsonrpc: "2.0",
      method: "echo",
      data: {
        x: "test"
      },
      id: "iowirpqiwr"
    }
    ws.send(msg.to_json)
  end

  ws.on :message do |event|
    p [:message, event.data]
    ws.send(event.data.to_s)
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
  end
}
