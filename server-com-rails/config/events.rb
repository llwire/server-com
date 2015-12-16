WebsocketRails::EventMap.describe do
  subscribe :client_connected, :to => RemoteClientController, :with_method => :connected

  subscribe :new_message, :to => RemoteClientController, :with_method => :message

  subscribe :client_disconnected, :to => RemoteClientController, :with_method => :disconnected
end
