require 'regrit/provider/mock'
require 'regrit/provider/system'

module Regrit
  module Provider
    def self.new(*args)
      if Regrit.mocking?
        Provider::Mock.new(*args)
      else
        Provider::System.new(*args)
      end
    end
  end
end
