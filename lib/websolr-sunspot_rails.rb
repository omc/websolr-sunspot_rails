require "sunspot_rails"
Sunspot.session = Sunspot::SessionProxy::SilentFailSessionProxy.new(Sunspot.session)