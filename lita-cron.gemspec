Gem::Specification.new do |spec|
  spec.name          = "lita-cron"
  spec.version       = "0.0.3"
  spec.authors       = ["Kit Plummer"]
  spec.email         = ["kitplummer@gmail.com"]
  spec.description   = %q{A Lita handler for creating cron-spec'd replies.}
  spec.summary       = %q{A Lita handler for creating cron-spec'd replies.}
  spec.homepage      = "http://kitplummer.github.com/"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 2.7"
  spec.add_runtime_dependency "rufus-scheduler", "2.0.24"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">= 3.0.0.beta2"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
