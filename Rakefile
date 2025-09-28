# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

configure_test_task = lambda do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end

Rake::TestTask.new(:test, &configure_test_task)

namespace :test do
  desc 'Run tests with coverage'
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task[:test].reenable
    Rake::Task[:test].invoke
  ensure
    Rake::Task[:test].reenable
    ENV.delete('COVERAGE')
  end
end

RuboCop::RakeTask.new(:rubocop)

desc 'Run full CI pipeline'
task :ci do
  Rake::Task['test:coverage'].invoke
  Rake::Task[:rubocop].invoke
ensure
  Rake::Task['test:coverage'].reenable
  Rake::Task[:rubocop].reenable
end
