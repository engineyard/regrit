require 'open4'
require 'escape'
require 'git-ssh-wrapper'

module Regrit
  module Provider
    class System
      DEFAULT_TIMEOUT = 5

      def initialize(uri, options)
        @uri = uri
        @timeout = options[:timeout] || DEFAULT_TIMEOUT
        load_git_ssh_wrapper(options) if @uri.ssh?
      end

      def ls_remote(named=nil)
        git "ls-remote", @uri.to_s, named
      end

      def clone(*argv)
        git "clone", *argv
      end

      def fetch(*argv)
        git "fetch", *argv
      end

      def push(*argv)
        git "push", *argv
      end

      def pull(*argv)
        git "pull", *argv
      end

      def git(*argv)
        spawn "#{git_command} #{Escape.shell_command(argv.flatten.compact)}"
      end

      protected

      # Only require open4 here so as not to set a hard dependency.
      #
      # Might raise CommandError or TimeoutError
      def spawn(command)
        stdout, stderr = '', ''
        Open4.spawn(command, :stdout => stdout, :stderr => stderr, :timeout => @timeout)
        stdout
      rescue Open4::SpawnError => e
        raise CommandError.new(e.cmd, e.exitstatus, stdout, stderr)
      rescue Timeout::Error
        raise TimeoutError.new(command, @uri)
      end

      def git_command
        # GIT_ASKPASS='echo' keeps password prompts from stalling the proccess (they still fail)
        "env GIT_ASKPASS='echo' #{@uri.ssh? ? @git_ssh_wrapper.git_ssh : ''} git"
      end

      def load_git_ssh_wrapper(options)
        @git_ssh_wrapper = GitSSHWrapper.new(options)
      rescue GitSSHWrapper::PrivateKeyRequired
        raise Regrit::PrivateKeyRequired.new(@uri)
      end
    end
  end
end
