module Regrit
  module Provider
    class Mock
      class NotImplemented < Regrit::Error
        def initialize
          super "Command not implemented."
        end
      end

      class << self
        attr_accessor :accessible
        attr_accessor :refs
        attr_accessor :timeout

        def default!
          self.accessible = true
          self.timeout = false
          self.refs = <<-REFS
123456789abcdef0123456789abcdef012345678\tHEAD
123456789abcdef0123456789abcdef012345678\trefs/heads/master
          REFS
        end
      end

      default!

      def initialize(uri, options)
        @uri = uri
        @options = options
      end

      def ls_remote(named=nil)
        raise_errors
        if named
          one_ref(named) || ''
        else
          self.class.refs
        end
      end

      def clone(*argv)
        raise NotImplemented
      end

      def fetch(*argv)
        raise NotImplemented
      end

      def push(*argv)
        raise NotImplemented
      end

      def pull(*argv)
        raise NotImplemented
      end

      protected


      def one_ref(named)
        self.class.refs.split(/\n/).detect do |ref|
          ref_name = ref.split(/\t/).last
          ref_name.split('/').last == named || ref_name.split('/',2).last == named || ref_name == named # git style matching
        end
      end

      def raise_errors
        if @uri.ssh?
          begin
            @git_ssh_wrapper ||= GitSSHWrapper.new(@options)
          rescue GitSSHWrapper::PrivateKeyRequired
            raise Regrit::PrivateKeyRequired.new(@uri)
          end
        end

        unless self.class.accessible
          raise CommandError.new('mock command', 1, '', 'stderr')
        end

        if self.class.timeout
          raise TimeoutError.new('mock command', @uri)
        end
      end

    end
  end
end
