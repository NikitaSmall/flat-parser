require 'dotenv'

require_relative './lib/atlant_parser'
require_relative './lib/president_parser'

Dotenv.load

task :atlant do
  parser = AtlantParser.new('https://www.atlanta.ua', distance: 3000,
    spreadsheet_id: '1jAoAM2CYqZoqirT0xNKIJEQ-rreA6pXEn04OnbwOKTw')
  parser.process
end

task :president do
  parser = PresidentParser.new('http://president.odessa.ua', distance: 3000,
    spreadsheet_id: '1jAoAM2CYqZoqirT0xNKIJEQ-rreA6pXEn04OnbwOKTw')
  parser.process
end
