require 'singleton'

class RpcResponseActor
  include Singleton

  @@socket_connector = WebsocketClientConnector.instance
  def initialize(response_channel='host', rpc_socket_url='ws://localhost:9000/client/local')
    @connection = @@socket_connector.get_or_create_connection(response_channel, rpc_socket_url)
    @connection.on :echo do |rpc_request|
      response = {
        jsonrpc: rpc_request['jsonrpc'],
        result: rpc_request['params'],
        id: rpc_request['id'],
      }
      @@socket_connector.send_message(response_channel, response)
    end
  end
end
