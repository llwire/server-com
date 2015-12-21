require  'singleton'

class WebsocketClientConnector
  include Singleton

  def initialize
    @@connections ||= {}
    @connection_attempts ||= 0
  end

  def send_message(connection_channel, message)
    connection = @@connections[connection_channel]
    puts connection
    connection.send(message)
  end

  def connection_to(connection_channel, connection_url)
    connection = WebSocket::Client::Simple.connect connection_url
    @@connections[connection_channel] = connection

    connection.on :message do |message|
      puts message
      WebsocketClientConnector.instance.handle_message(connection_channel, message)
    end

    connection.on :close do |error|
      puts "CLOSE!"
      @@connections.delete(connection_channel)
    end

    connection.on :error do |error|
      puts error
      @@connections.delete(connection_channel)
    end
  end

  def handle_message(target, message)
    puts message
    send_message(target, message)
  end

end
