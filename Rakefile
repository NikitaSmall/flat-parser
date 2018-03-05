require 'dotenv'

require_relative './lib/atlant_parser'

Dotenv.load

task :atlant do
  parser = AtlantParser.new('https://www.atlanta.ua')
  parser.process
end
