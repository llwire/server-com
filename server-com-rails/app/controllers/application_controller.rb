class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    conn = WebsocketClientConnector.new( 'test', 'ws://localhost:3000/websocket' )
    conn.send_message( '["new_message",{"data":"Example message"}]' )
  end

end
