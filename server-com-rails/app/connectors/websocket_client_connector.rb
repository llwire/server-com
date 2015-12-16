require 'rubygems'
require 'websocket-client-simple'

class WebsocketClientConnector

  def initialize(connection_target_name, connection_endpoint_url)
    @@connections ||= {}
    @connection_attempts ||= 0
    setup(connection_target_name, connection_endpoint_url)
  end

  def send_message(message)
    @connection.send(message)
  end

  private

  def setup(connection_target_name, connection_endpoint_url)
    @connection = WebSocket::Client::Simple.connect connection_endpoint_url
    @@connections[connection_target_name] = @connection

    @connection.on :message do |message|
      handle_message(message)
    end

    @connection.on :error do |error|
      @connection_attempts += 1
      setup(connection_target_name, connection_endpoint_url) if @connection_attempts < 5
    end
  end

  def handle_message(message)
    puts message
  end

end
