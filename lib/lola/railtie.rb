require 'lola'
require 'rails'

module Lola
  module Rails
    class Railtie < ::Rails::Railtie
      config.after_initialize do
        require 'lola/helpers'
      end
    end
  end
end
