desc "Load the environment"
task :environment do
  require File.expand_path('../../lib/qio', __FILE__)
end