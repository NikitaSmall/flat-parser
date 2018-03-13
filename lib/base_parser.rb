require 'json'
require 'erb'
require 'open-uri'
require 'logger'

require 'google_drive'

class BaseParser
  GOOGLE_DRIVE_API_CONFIG = File.join(File.dirname(__FILE__), '..', 'api_key.json').freeze
  GOOGLE_SHEET_NAME = "flat-search-#{Time.now.to_s}".freeze

  def initialize(base_url, spreadsheet_id:, price: 50000, distance: 5000,
                           city: 'Одесса', init_position: 'Маразлиевская')
    @base_url = base_url
    @data = []

    @desired_price = price
    @desired_distance = distance

    @city = city
    @init_position = init_position

    @spreadsheet_id = spreadsheet_id

    @logger = Logger.new(STDOUT)

    @whitelist = []
  end

  def process
    collect
    filter
    save
  end

  def collect
    raise NotImplementedError, 'implement `collect` method in the child'
  end

  def filter
    raise NotImplementedError, 'implement `filter` method in the child'
  end

  def save
    ws = GoogleDrive::Session.from_service_account_key(GOOGLE_DRIVE_API_CONFIG).
      spreadsheet_by_key(@spreadsheet_id).add_worksheet(GOOGLE_SHEET_NAME, 1000, 10)

    save_data(ws)
  end

  protected

  DISTANCE_REQUEST = 'https://maps.googleapis.com/maps/api/distancematrix/json' \
    '?units=metric&origins=%{from}&destinations=%{to}&key=%{api_key}'.freeze

  GOOGLE_SHEET_HEADERS = %w(# title address size price link).freeze
  GOOGLE_SHEET_OFFSET = 2

  def distance(from, to)
    params = {
      from: "#{@city}, #{from}",
      to: "#{@city}, #{to}",
      api_key: ENV['GOOGLE_MAPS_API_KEY']
    }

    url = URI.encode(DISTANCE_REQUEST % params)
    google_distance_data = JSON.parse(open(url).read)
    google_distance_data['rows'][0]['elements'][0]['distance']['value']
  rescue NoMethodError
    0
  end

  def save_data(ws)
    GOOGLE_SHEET_HEADERS.each_with_index do |column_name, index|
      ws[1, index + 1] = column_name
    end

    @data.each_with_index do |flat, index|
      ws[index + GOOGLE_SHEET_OFFSET, 1] = index + 1
      ws[index + GOOGLE_SHEET_OFFSET, 2] = flat[:title]
      ws[index + GOOGLE_SHEET_OFFSET, 3] = flat[:address]
      ws[index + GOOGLE_SHEET_OFFSET, 4] = flat[:size]
      ws[index + GOOGLE_SHEET_OFFSET, 5] = flat[:price]
      ws[index + GOOGLE_SHEET_OFFSET, 6] = flat[:link]
    end

    ws.save
  end

  def load_whitelist(list_name)
    @whitelist = File.read(File.join(File.dirname(__FILE__), '..', 'whitelists', list_name)).split(',')
  end
end
