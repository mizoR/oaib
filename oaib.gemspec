# frozen_string_literal: true

require_relative "lib/oaib/version"

Gem::Specification.new do |spec|
  spec.name = "oaib"
  spec.version = Oaib::VERSION
  spec.authors = ["mizokami"]
  spec.email = ["r.mizokami@gmail.com"]

  spec.summary = "OpenAI Batch CLI."
  spec.description = "OpenAI Batch CLI."
  spec.homepage = "https://github.com/mizoR/oaib"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/mizoR/oaib"
  spec.metadata["changelog_uri"] = "https://github.com/mizoR/oaib"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby-openai", "~> 7.3"
end
