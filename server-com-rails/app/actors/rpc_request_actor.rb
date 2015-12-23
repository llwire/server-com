class RpcRequestActor
  @@socket_connector = WebsocketClientConnector.instance

  def initialize(request_channel, rpc_socket_url, rpc_request_data, response_stream)
    @connection = @@socket_connector.get_or_create_connection(request_channel, rpc_socket_url)
    @connection.once :result do |rpc_response|
      puts rpc_response
      response_stream.write(rpc_response)
      response_stream.close
    end
    @connection.once :error do |rpc_response|
      puts "Error!"
    end

    @connection.send_message(rpc_request_data)
  end
end
