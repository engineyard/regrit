# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "regrit/version"

Gem::Specification.new do |s|
  s.name        = "regrit"
  s.version     = Regrit::VERSION
  s.authors     = ["Martin Emde"]
  s.email       = ["martin.emde@gmail.com"]
  s.homepage    = "http://github.com/engineyard/regrit"
  s.summary     = %q{Never regrit how you talk with remote git repositories}
  s.description = %q{Deal with remote git repositories, yo.}

  s.license = 'MIT'

  s.add_dependency "gitable",         "~> 0.2.1"
  s.add_dependency "open4"
  s.add_dependency "escape"
  s.add_dependency "git-ssh-wrapper", "~> 0.1.0"
  s.add_dependency "system-timer19",  "~> 0.0.2"

  if RUBY_VERSION =~ /^1\.8/
    s.add_dependency "SystemTimer"
  end
  
  s.add_development_dependency "rspec", "~> 2.0"
  s.add_development_dependency "rake", "~> 0.9"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
