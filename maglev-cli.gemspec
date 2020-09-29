# frozen_string_literal: true

require_relative 'lib/maglev/cli'

Gem::Specification.new do |spec|
  spec.name          = 'maglev-cli'
  spec.version       = Maglev::CLI::VERSION
  spec.authors       = ['Rodrigo Alvarez']
  spec.email         = ['papipo@gmail.com']

  spec.summary       = 'Maglev command line interface.'
  spec.description   = 'Eases setting up Maglev on existing Rails apps.'
  spec.homepage      = 'https://github.com/maglevhq/maglev-cli'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = [spec.homepage, '/CHANGELOG.md'].join

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'thor', '1.0.1'
end
