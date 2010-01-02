require 'rake/testtask'
require 'rcov/rcovtask'

task :default => :test

Rake::TestTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
  t.ruby_opts = ['-Itest', '-rubygems']
end

Rcov::RcovTask.new do |t|
  t.test_files = FileList['test/*_test.rb']
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new(:doc) do |t|
    t.options = ['--no-private']
    t.files = FileList['lib/**/*.rb']
  end
rescue LoadError => e
  puts "yard not available. Install it with: gem install yard"
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = 'attribute_mapper'
    s.summary = 'Map symbolic types to primitive types and stash them in a column.'
    s.email = 'adamkkeys@gmail.com'
    s.homepage = 'http://github.com/therealadam/attribute_mapper'
    s.description = 'Provides a transparent interface for mapping symbolic representations to a column in the database of a more primitive type.'
    s.authors = ['Marcel Molina Jr.', 'Bruce Williams', 'Adam Keys']
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install technicalpickles-jeweler -s http://gems.github.com"
end
