# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{attribute_mapper}
  s.version = "0.9.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcel Molina Jr.", "Bruce Williams", "Adam Keys"]
  s.date = %q{2009-03-10}
  s.description = %q{Provides a transparent interface for mapping symbolic representations to a column in the database of a more primitive type.}
  s.email = %q{adamkkeys@gmail.com}
  s.files = ["README.md", "VERSION.yml", "lib/attribute_mapper.rb", "test/attribute_mapper_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/therealadam/attribute_mapper}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Map symbolic types to primitive types and stash them in a column.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
