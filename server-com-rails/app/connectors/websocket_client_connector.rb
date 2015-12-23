require 'singleton'
require 'json'

class WebsocketClientConnector
  include Singleton

  def initialize
    @@connections ||= {}
    @connection_attempts ||= 0
  end

  def send_message(connection_channel, message)
    connection = @@connections[connection_channel]
    connection.send(message.to_json)
  end

  def channel_exists?(connection_channel)
    @@connections.key?(connection_channel)
  end

  def get_or_create_connection(connection_channel, connection_url)
    return @@connections[connection_channel] if channel_exists?(connection_channel)
    return connection_to(connection_channel, connection_url)
  end

  def close_connection(connection_channel)
    return unless channel_exists?(connection_channel)
    @@connections[connection_channel].close
  end

  def connection_to(connection_channel, connection_url)
    connection = WebSocket::Client::Simple.connect connection_url
    @@connections[connection_channel] = connection

    connection.on :message do |message|
      WebsocketClientConnector.instance.handle_message(connection, message)
    end

    connection.on :close do |event|
      puts "Closing connection ..."
      @@connections.delete(connection_channel)
    end

    connection.on :error do |error|
      puts "Error: #{error}"
      #@@connections[connection_channel].close
      #@@connections.delete(connection_channel)
    end

    return connection
  end

  def handle_message(connection, message)
    puts message
    parsed_message = JSON.parse(message.data)
    if(parsed_message.key?('method'.freeze))
      connection.emit parsed_message['method'].to_sym, parsed_message
    elsif(parsed_message.key?('result'.freeze))
      connection.emit :result, parsed_message
    elsif(parsed_message.key?('error'.freeze))
      connection.emit :error, parsed_message['error']
    else
      puts message
    end
  end

end
