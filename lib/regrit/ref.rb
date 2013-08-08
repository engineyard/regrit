module Regrit
  class Ref
    def initialize(repo, ref)
      @repo = repo
      @commit, @full_name = ref.split(/\t/)
      @type, @name = @full_name.scan(%r#refs/([^/]+)/(.+)#).first || [nil, @full_name]
      raise InvalidRefsFormat.new(ref) if @name.nil?
    end

    attr_reader :commit, :full_name, :name, :type

    def tag?
      type == 'tags'
    end

    def branch?
      type == 'heads'
    end

    def abbrev_commit
      commit[0...7]
    end

    def match?(named)
      name == named || full_name == named || [type,name].compact.join('/') == named
    end
  end
end
