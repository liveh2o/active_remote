module ActiveRemote
  class Railtie < Rails::Railtie
    config.active_remote = ActiveRemote.config
  end
end
