require 'nokogiri'
require 'open-uri'

require_relative './base_parser'

class AtlantParser < BaseParser
  LINKS = [
    '/filters/?search_type=simple&deal_type=sale&realty_type=flat&' \
    'top_district=primorskiy&region_type=odessa&currency=usd&exclusive=0' \
    '&max_price=%{desired_price}&min_floor=2&page=%{page_number}'
  ].freeze

  def collect
    LINKS.each { |link| collect_from_page(link) }
  end

  def filter
    @data.select { |flat| flat[:title] != 'Коммунальная' }
  end

  private

  def collect_from_page(link)
    1.step do |page_number|
      prepared_link = link % { desired_price: @desired_price, page_number: page_number }

      flats = Nokogiri::HTML(open("#{@base_url}#{prepared_link}")).css('.object.object--')
      break if flats.size == 0

      flats.each do |flat|
        @data << {
          title: flat.at_css('.object-title').text.strip,
          size: flat.at_css('.object-sqr').text.strip,
          address: flat.at_css('.object-address').text.strip,
          price: flat.at_css('.object-price').text.strip,
          link: flat.at_css('.object-title')['href']
        }
      end
    end
  end
end
