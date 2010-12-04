module Regrit
  # Error base class
  class Error < RuntimeError
  end

  # Raised when the URI received is not a valid or able to be parsed.
  class InvalidURIError < Error
    def initialize
      super "Invalid repository URI"
    end
  end

  # Raised when a repository is not accessible in some form.
  class Inaccessible < Error
    def initialize(message)
      super "Repository Inaccessible: #{message}"
    end
  end

  # Raised when a secure repository is accessed without a key
  class PrivateKeyRequired < Inaccessible
    def initialize(uri)
      super "SSH private key required for secure git repository: #{uri}"
    end
  end

  # Raised when there is an error calling git ls-remote (i.e. inaccessible repo)
  class CommandError < Inaccessible
    def initialize(command, status, stdout, stderr)
      super <<-ERROR
Command `#{command}` exited with a non-zero exit status [#{status}]:
stdout:
#{stdout}

stderr:
#{stderr}
      ERROR
    end
  end

  # Raised when the Refs format is unrecognized
  class InvalidRefsFormat < Inaccessible
    def initialize(raw_refs)
      super <<-ERROR
Invalid git refs format:
#{raw_refs}
      ERROR
    end
  end

end
