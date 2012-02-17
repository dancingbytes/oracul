# encoding: utf-8
module Goliath

  class Server

    def load_config(file = nil)
      
      file ||= File.join(config_dir, "#{Goliath.env}.rb")
      return unless File.exists?(file)

      eval(IO.read(file))

    end # load_config

    def config_dir
      File.join(::Oracul.root, "config", "environments")
    end # config_dir

  end # Server

end # Goliath