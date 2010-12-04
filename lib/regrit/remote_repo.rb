require 'gitable'
require 'open4'
require 'escape'
require 'regrit/ref'
require 'git-ssh-wrapper'

module Regrit
  class RemoteRepo

    DEFAULT_TIMEOUT = 5
    REFS_REGEXP     = /^[0-9a-f]{40}\t\w/i

    attr_reader :uri

    def initialize(uri, options={})
      @uri = Gitable::URI.parse(uri)
      if @uri.to_s.empty?
        raise InvalidURIError
      end
      @timeout = options[:timeout] || DEFAULT_TIMEOUT
      load_git_ssh_wrapper(options) if auth_required?
    rescue TypeError, Gitable::URI::InvalidURIError
      raise InvalidURIError
    end

    # Decide if the URI is likely to require authentication
    # @return [Boolean] Does the repo require auth?
    def auth_required?
      @uri.user || @uri.scheme == 'ssh'
    end

    # Attempt to grab refs. If the repository is auth required and a private key
    # is passed, use ssh to attempt access to the repository.
    #
    # @return [Boolean] can the repository be accessed?
    def accessible?
      !!refs
    rescue Inaccessible, TimeoutError
      false
    end

    # Use a git ls-remote to load all repository refs
    #
    # @return [Array] An Array of Ref objects
    def refs
      @refs ||= load_refs
    end

    # Use a git ls-remote to load all repository refs
    #
    # @return [Ref, nil] A Ref object or nil
    def ref(named)
      load_refs(named).first
    end

    private

    def load_refs(name=nil)
      raw_refs = git('ls-remote', uri.to_s, name)

      return [] if raw_refs.empty?

      unless raw_refs =~ REFS_REGEXP
        raise InvalidRefsFormat.new(raw_refs)
      end

      raw_refs.split(/\n/).map { |ref| Ref.new(self, ref) }
    end

    def git(*argv)
      stdout, stderr = spawn("#{git_command} #{Escape.shell_command(argv.compact)}")
      return stdout
    end

    # Only require open4 here so as not to set a hard dependency.
    #
    # Might raise TimeoutError
    def spawn(command)
      stdout, stderr = '', ''
      Open4.spawn(command, :stdout => stdout, :stderr => stderr, :timeout => @timeout)
      return [stdout, stderr]
    rescue Open4::SpawnError => e
      raise CommandError.new(e.cmd, e.exitstatus, stdout, stderr)
    end

    def load_git_ssh_wrapper(options)
      @git_ssh_wrapper = GitSSHWrapper.new(options)
    rescue GitSSHWrapper::PrivateKeyRequired
      raise Regrit::PrivateKeyRequired.new(@uri)
    end

    def git_command
      # GIT_ASKPASS='echo' keeps password prompts from stalling the proccess (they still fail)
      "env GIT_ASKPASS='echo' #{auth_required? ? @git_ssh_wrapper.git_ssh : ''} git"
    end
  end
end
