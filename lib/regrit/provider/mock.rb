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

        def default!
          self.accessible = true
          self.refs = <<-REFS
123456789abcdef0123456789abcdef012345678\tHEAD
123456789abcdef0123456789abcdef012345678\trefs/heads/master
          REFS
        end
      end

      default!

      def initialize(uri, options)
      end

      def ls_remote(named=nil)
        raise_if_not_accessible!
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

      def raise_if_not_accessible!
        unless self.class.accessible
          raise CommandError.new('mock command', 1, '', 'stderr')
        end
      end

    end
  end
end
