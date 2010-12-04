unless defined? Bundler
  require 'rubygems'
  require 'bundler'
  Bundler.setup
end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'regrit'
require 'spec'

module TestPrivateKey
  def private_key
    Pathname.new('spec/id_rsa').read
  end

  def wrong_private_key
    Pathname.new('spec/wrong_key').read
  end

  def private_key_path
    Pathname.new('spec/id_rsa').to_s
  end
end

Spec::Runner.configure do |config|
  config.include TestPrivateKey
end
