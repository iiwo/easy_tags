# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_tags/version'

Gem::Specification.new do |spec|
  spec.name = 'easy_tags'
  spec.version = EasyTags::VERSION
  spec.authors = ['Iwo Dziechciarow']
  spec.email = ['iiwo@o2.pl']

  spec.summary = 'EasyTags allows you to tag a single model on several contexts'
  spec.description = 'Easy tagging for Rails'
  spec.homepage = 'https://github.com/iiwo/easy_tags'
  spec.license = 'MIT'
  spec.metadata    = {
    'homepage_uri' => 'https://github.com/iiwo/easy_tags',
    'changelog_uri' => 'https://github.com/iiwo/easy_tags/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/iiwo/easy_tags',
    'bug_tracker_uri' => 'https://github.com/iiwo/easy_tags/issues',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = ['>= 2.5.0', '<= 4.0.0']

  spec.add_runtime_dependency 'activerecord', '>= 5.0'
  spec.add_runtime_dependency 'activesupport', '>= 5.0'
end
