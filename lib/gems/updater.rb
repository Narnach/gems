require 'gems/config'

module Gems
  class Updater < Gems::Config
    def update
      load_config
      save_config
    end
  end
end

GemsList = Gems::List
