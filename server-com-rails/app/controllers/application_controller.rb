require 'rpc_request_actor'

class ApplicationController < ActionController::Base
  include ActionController::Live

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def index
    rpc_requester = RpcRequestActor.new(
      'echo-machine'.freeze,
      'ws://localhost:9000/client/remote'.freeze,
      {
        jsonrpc: "2.0",
        method: "echo",
        params: {
          x: "test"
        },
        id: "iowirpqiwr"
      },
      response.stream
    )
    sleep 2
  end

end
