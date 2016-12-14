# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'misty_builder/version'

Gem::Specification.new do |spec|
  spec.name          = "misty-builder"
  spec.version       = MistyBuilder::VERSION
  spec.authors       = ["Gilles Dubreuil"]
  spec.email         = ["gilles@redhat.com"]

  spec.summary       = %q{OpenStack APIs builder for misty.}
  spec.description   = %q{Automated API definitions from OpenStackś API Reference.}
  spec.homepage      = "https://github.com/gildub/misty-builder"
  spec.license       = "GPL-3.0"

  all_files       = `git ls-files -z`.split("\x0")
  spec.files         = all_files.grep(%r{^(exe|lib|test)/|^.rubocop.yml$})
  spec.executables   = all_files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.bindir        = "exe"
  spec.require_paths = ['lib']

  spec.rdoc_options = ['--charset=UTF-8']
  spec.extra_rdoc_files = %w[README.md LICENSE.md]

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake',    '~> 10.0'
  spec.add_development_dependency 'nokogiri', '~> 1.6'
  spec.add_development_dependency 'pry-byebug', '~> 3.4'
end
