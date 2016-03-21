require 'rake/clean'
require 'rake/testtask'

require 'yard'

CLEAN << 'coverage/'
CLEAN << 'doc/'

task :environment do
  require_relative './ash_frame'
end

namespace :db do
  desc "Runs the Sequel migrations"
  task migrate: :environment do
    puts "Running migrations"

    Sequel.extension :migration
    Sequel::Migrator.run DB, AshFrame.root.join('db', 'migrations')
  end

  desc "Seeds the database with the nescessary starting data"
  task seed: :environment do
    puts "Loading seed data"

    require_relative './db/seeds'
  end

  desc "Reset, migrate and reseed seed"
  task reset: :environment do
    puts "Droping existing tables"
    DB.run 'DROP SCHEMA IF EXISTS public CASCADE'
    DB.run 'CREATE SCHEMA IF NOT EXISTS public;'
    Rake::Task['db:migrate'].execute
    Rake::Task['db:seed'].execute
  end
end

Rake::TestTask.new do |t|
  t.pattern = "test/**/*test.rb"
end

task default: :test

namespace :test do
  desc 'Generates a coverage report'
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['test'].execute
  end

  desc "Generates missing test files"
  task :generate do
    Dir[ 'lib/**/*.rb', 'app/**/*.rb' ].map do |f|
      Pathname.new('test') + f.gsub('.rb', '_test.rb')
    end.each do |filename|
      unless File.exist? filename
        puts "Creating #{ filename }"
        FileUtils.mkdir_p filename.dirname unless File.directory? filename.dirname
        FileUtils.touch filename
      end
    end
  end
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb', 'app/**/*.rb', 'initializers/**/*.rb', 'spacescrape.rb']
  t.options = [ '-', 'README.md' ]
  # t.stats_options = ['--list-undoc']
end

# load 'tasks/emoji.rake'
