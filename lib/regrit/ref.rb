module Regrit
  class Ref
    def initialize(repo, ref)
      @repo = repo
      @commit, @name = ref.split(/\t/)
      raise InvalidRefsFormat.new(ref) if @name.nil?
    end

    attr_reader :commit, :name

    def abbrev_commit
      commit[0...7]
    end
  end
end
