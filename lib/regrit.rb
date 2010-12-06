module Regrit
  @mocking = false

  def self.enable_mock!
    Provider::Mock.default!
    @mocking = true
  end

  def self.disable_mock!
    @mocking = false
  end

  def self.mocking?
    @mocking
  end
end

require 'regrit/errors'
require 'regrit/remote_repo'
require 'regrit/provider'
