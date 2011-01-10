require 'gitable'
require 'regrit/ref'

module Regrit
  class RemoteRepo

    REFS_REGEXP = /^[0-9a-f]{40}\t\w/i

    attr_reader :uri

    def initialize(uri, options={})
      if uri.nil? || uri.empty?
        raise InvalidURIError
      end

      begin
        @uri = Gitable::URI.parse(uri)
      rescue TypeError, Gitable::URI::InvalidURIError
        raise InvalidURIError
      end

      # no user without ssh and no ssh without user - ^ is the XOR operator
      if @uri.ssh? ^ @uri.user
        raise InvalidURIError
      end

      @provider = Provider.new(@uri, options)
    end

    # Decide if the URI is likely to require authentication
    # @return [Boolean] Does the repo require auth?
    def private_key_required?
      @uri.ssh?
    end

    # Attempt to grab refs. If the repository is auth required and a private key
    # is passed, use ssh to attempt access to the repository.
    #
    # @return [Boolean] can the repository be accessed?
    def accessible?
      !!refs
    rescue Inaccessible
      false
    end

    # Use a git ls-remote to load all repository refs
    #
    # @return [Array] An Array of Ref objects
    def refs
      @refs ||= load_refs
    end

    # Use a git ls-remote to find a single ref
    #
    # @return [Ref, nil] A Ref object or nil
    def ref(named)
      load_refs(named).first
    end

    private

    attr_reader :provider

    def load_refs(named=nil)
      raw_refs = provider.ls_remote(named)

      return [] if raw_refs.empty?

      unless raw_refs =~ REFS_REGEXP
        raise InvalidRefsFormat.new(raw_refs)
      end

      raw_refs.split(/\n/).map { |ref| Ref.new(self, ref) }
    end
  end
end
