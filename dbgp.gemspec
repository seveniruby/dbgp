# -*- encoding: utf-8 -*-
require File.expand_path('../lib/dbgp/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["seveniruby"]
  gem.email         = ["seveniruby@gmail.com"]
  gem.description   = %q{debug platform for php and c, php use xdebug, c use gdb}
  gem.summary       = %q{debug platform}
  gem.homepage      = "https://github.com/seveniruby/dbgp"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "dbgp"
  gem.require_paths = ["lib"]
  gem.version       = DBGP::VERSION
end
