$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "evolution/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "evolution"
  s.version     = Evolution::VERSION
  s.authors     = ["Nicholas Jakobsen", "Ryan Wallace"]
  s.email       = ["nicholas@culturecode.ca", "ryan@culturecode.ca"]
  s.homepage    = "http://www.culturecode.ca"
  s.summary     = "Track the evolution of your records."
  s.description = "Evolve your records from generation to generation, splitting a record into
                   multiple lineages, or converging multiple lineages back into a single one."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 4.0", "< 7.1"
  s.add_runtime_dependency "acts_as_dag", ">= 2"

  s.add_development_dependency "sqlite3"
end
