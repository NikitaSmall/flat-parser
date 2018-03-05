require 'dotenv'

require_relative './lib/atlant_parser'

Dotenv.load

task :atlant do
  parser = AtlantParser.new('https://www.atlanta.ua', distance: 3000,
    spreadsheet_id: '1jAoAM2CYqZoqirT0xNKIJEQ-rreA6pXEn04OnbwOKTw')
  parser.process
end
