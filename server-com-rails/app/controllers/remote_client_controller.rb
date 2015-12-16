require 'rubygems'
require 'websocket-rails'

class RemoteClientController < WebsocketRails::BaseController

  def connected
    puts '-'*40
  end

  def disconnected
    puts '&'*40
  end

  def message
    puts ')'*40
  end

end
