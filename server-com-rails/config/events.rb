WebsocketRails::EventMap.describe do
  subscribe :new_message, :to => RemoteClientController, :with_method => :new_message

  subscribe :connection_closed, :to => RemoteClientController, :with_method => :connection_closed

  subscribe :client_connected, :to => RemoteClientController, :with_method => :user_connected

  subscribe :client_disconnected, :to => RemoteClientController, :with_method => :user_disconnected
end
