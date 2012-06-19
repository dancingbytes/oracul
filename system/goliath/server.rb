# encoding: utf-8
module Oracul

  module Goliath

    class Server < ::Goliath::Server

      class << self
        attr_accessor :config, :plugins, :options
      end # class << self

      def load_config(file = nil)

        file ||= ::File.join(config_dir, "#{::Goliath.env}.rb")
        return unless ::File.exists?(file)

        instance_eval(::IO.read(file), file)

        self.class.config   = config
        self.class.plugins  = plugins
        self.class.options  = options

      end # load_config

      def config_dir
        File.join(::Oracul.root, "environments")
      end # config_dir

    end # Server

  end # Goliath

end # Oracul