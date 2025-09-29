# frozen_string_literal: true

require_relative 'lib/lenex/parser/version'

Gem::Specification.new do |spec|
  spec.name          = 'lenex-parser'
  spec.version       = Lenex::Parser::VERSION
  spec.authors       = ['TODO: Add author']
  spec.email         = ['TODO: Add email']

  spec.summary       = 'Fast and lightweight SAX parser for Lenex 3 swim files.'
  spec.description   = 'Provides streaming parsing tools for Lenex v3 swim data exchange.'
  spec.homepage      = 'https://example.com/lenex-parser'
  spec.license       = 'MIT'

  spec.metadata['allowed_push_host'] = 'TODO: Set to your gem server'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://example.com/lenex-parser'
  spec.metadata['changelog_uri'] = 'https://example.com/lenex-parser/changelog'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.required_ruby_version = '>= 3.1'

  spec.files = Dir.glob('lib/**/*') +
               Dir.glob('bin/*') +
               %w[README.md LICENSE lenex-parser.gemspec Rakefile .rubocop.yml .yardopts]
  spec.files.uniq!
  spec.files.reject! { |path| File.directory?(path) }

  spec.bindir        = 'bin'
  spec.executables   = Dir.children('bin').grep_v(/\A\./)
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '>= 1.14'
  spec.add_dependency 'rubyzip', '>= 2.3'
end
