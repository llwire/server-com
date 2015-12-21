require 'websocket_client_connector'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    connection = WebsocketClientConnector.instance.connection_to("test".freeze, "ws://localhost:9000/client/local".freeze)
  end

end
