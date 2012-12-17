# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qqwry/version'

Gem::Specification.new do |gem|
  gem.name          = "qqwry"
  gem.version       = QQWry::VERSION
  gem.authors       = ["Changli Gao"]
  gem.email         = ["xiaosuo@gmail.com"]
  gem.description   = %q{A Ruby interface for QQWry IP database}
  gem.summary       = %q{A Ruby interface for QQWry IP database}
  gem.homepage      = 'https://github.com/xiaosuo/qqwry'
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = 'MIT'
  gem.add_dependency  'bindata'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'bindata'
end
