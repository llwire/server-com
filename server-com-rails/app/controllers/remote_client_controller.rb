class RemoteClientController < WebsocketRails::BaseController

  def user_connected
    puts 'Connected ...'
  end

  def user_disconnected
    puts 'Disconnected ...'
  end

  def connection_closed
    puts 'Connection closed ...'
  end

  def new_message
    puts 'New message!'
  end

end
