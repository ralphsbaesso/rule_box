# frozen_string_literal: true

require_relative 'lib/rule_box/version'

Gem::Specification.new do |spec|
  spec.name          = 'rule_box'
  spec.version       = RuleBox::VERSION
  spec.authors       = ['Ralph Baesso', 'Nathan Meira']
  spec.email         = ['ralphsbaesso@gmail.com', 'nathanmeira1@gmail.com']

  spec.summary       = 'RuleBox'
  spec.description   = 'This gem is focused in giving a strong and concrete way to manage your business rules, mixing the best of both worlds in Facade and Strategy, bringing you a simplified way to apply these Design Patterns into your project.'
  spec.homepage      = 'https://github.com/ralphsbaesso/rule_box'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.0.0')

  # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/ralphsbaesso/rule_box'
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
