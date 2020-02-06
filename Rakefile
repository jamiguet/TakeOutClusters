require 'rake'
require 'rake/testtask'
require 'net/http'
require 'rake/clean'


desc "Doc string to build a project"

task :display_doc do
  puts "This is a simple documentation"
end

Rake::TestTask.new do |t|
  t.libs << "tests"
  t.test_files = FileList['tests/test_*.rb']
  t.verbose = true
end

namespace :sample_data do
  desc "Fetch sample data from server"
  task :fetch do
    Net::HTTP.start("jamiguet.blinkenshell.org") do |http|
      resp = http.get("/takeout_subset.json")
      open("takeout_subset.json", "w") { |file| file.write(resp.body) }
    end
  end

  task :clean do
    rm_f FileList['takeout_subset.json']
  end
end

task :run do
  ruby "src/compute_clusters.rb -ftakeout_subset.json"
end
