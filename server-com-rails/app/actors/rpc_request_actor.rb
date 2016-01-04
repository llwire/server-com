class RpcRequestActor
  @@socket_connector = WebsocketClientConnector.instance

  def initialize(request_channel, rpc_socket_url, rpc_request_data, response)
    @connection = @@socket_connector.get_or_create_connection(request_channel, rpc_socket_url)
    @connection.once :result do |rpc_response|
      puts rpc_response
      response.stream.write(rpc_response)
      response.stream.close
    end
    @connection.once :error do |rpc_response|
      puts "Error!"
    end
    puts rpc_request_data.to_json
    @connection.send(rpc_request_data.to_json)
  end
end
