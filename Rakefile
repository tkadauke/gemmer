require File.dirname(__FILE__) + '/src/gemmer'
require 'rake/testtask'

Gemmer::Tasks.new('gemmer') do |t|
  t.release_via :rubygems
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the gemmer gem unit tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'src'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end
