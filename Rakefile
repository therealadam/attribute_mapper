require 'rake/testtask'

task :default => :test

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts = ['-rubygems']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = 'AttributeMapper'
    s.summary = 'Map symbolic types to primitive types and stash them in a column.'
    s.email = 'adamkkeys@gmail.com'
    s.homepage = 'http://github.com/therealadam/attribute_mapper'
    s.description = 'AttributeMapper provides a transparent interface for mapping symbolic representations to a column in the database of a more primitive type.'
    s.authors = ['Marcel Molina Jr.', 'Bruce Williams', 'Adam Keys']
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install technicalpickles-jeweler -s http://gems.github.com"
end