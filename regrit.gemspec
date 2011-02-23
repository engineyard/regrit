# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "regrit/version"

Gem::Specification.new do |s|
  s.name        = "regrit"
  s.version     = Regrit::VERSION
  s.authors     = ["Martin Emde"]
  s.email       = ["martin.emde@gmail.com"]
  s.homepage    = "http://github.org/martinemde/regrit"
  s.summary     = %q{Never regrit how you talk with remote git repositories}
  s.description = %q{Deal with remote git repositories, yo.}

  s.add_dependency "gitable", "~> 0.2.1"
  s.add_dependency "open4"
  s.add_dependency "escape"
  s.add_dependency "git-ssh-wrapper", "~> 0.0.1"
  s.add_dependency "SystemTimer"

  s.add_development_dependency "rspec", "~> 2.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "rcov"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
