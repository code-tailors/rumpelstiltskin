# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rumpydb/version'

Gem::Specification.new do |gem|
  gem.name          = "rumpydb"
  gem.version       = RumpyDB::VERSION
  gem.authors       = ["blanchma"]
  gem.email         = ["tute.unique@gmail.com"]
  gem.description   = %q{A standalone dwarf database}
  gem.summary       = %q{A standalone database packaged in a folder}
  gem.homepage      = "http://rumbydb.com"

  gem.files         = [ "README.rdoc", "LICENSE", "Rakefile" ] + Dir["lib/**/*"] + Dir["test/**/*"] #`git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test)/})
  gem.require_paths = ["lib"]
  gem.add_development_dependency("minitest")
end
