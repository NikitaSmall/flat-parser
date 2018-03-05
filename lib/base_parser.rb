require 'json'
require 'erb'
require 'open-uri'

class BaseParser
  DISTANCE_REQUEST = 'https://maps.googleapis.com/maps/api/distancematrix/json' \
    '?units=metric&origins=%{from}&destinations=%{to}&key=%{api_key}'.freeze

  def initialize(base_url, price: 50000, distance: 5000,
                           city: 'Одесса', init_position: 'парк Шевченко')
    @base_url = base_url
    @data = []

    @desired_price = price
    @desired_distance = distance

    @city = city
    @init_position = init_position
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
    require 'pp'
    pp @data
  end

  protected

  def distance(from, to)
    params = {
      from: "#{@city}, #{from}",
      to: "#{@city}, #{to}",
      api_key: ENV['GOOGLE_MAPS_API_KEY']
    }

    url = URI.encode(DISTANCE_REQUEST % params)
    google_distance_data = JSON.parse(open(url).read)
    google_distance_data['rows'][0]['elements'][0]['distance']['value']
  end
end
