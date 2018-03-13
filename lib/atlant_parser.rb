require 'nokogiri'

require_relative './base_parser'

class AtlantParser < BaseParser
  LINKS = [
    '/filters/?search_type=simple&deal_type=sale&realty_type=flat&' \
    'top_district=primorskiy&region_type=odessa&currency=usd&exclusive=0' \
    '&max_price=%{desired_price}&min_floor=2&page=%{page_number}'
  ].freeze

  def initialize(base_url, spreadsheet_id:, price: 50000, distance: 5000,
                           city: 'Одесса', init_position: 'Маразлиевская')
    super
    load_whitelist('atlant.txt')
  end

  def collect
    LINKS.each { |link| collect_from_page(link) }
  end

  def filter
    @logger.info("Flats before filter: #{@data.length}")

    @data.select! { |flat| flat[:title] != 'Коммунальная' }
    @data.select! { |flat| @whitelist.any? { |whiteflat| flat[:address].include?(whiteflat) } }

    @data.select! do |flat|
      pure_address = flat[:address][flat[:address] =~ /,([а-яА-Я ]+)/...flat[:address].length]
      distance(@init_position, pure_address) < @desired_distance
    end

    @logger.info("Flats after filter: #{@data.length}")
  end

  private

  def collect_from_page(link)
    1.step do |page_number|
      prepared_link = link % { desired_price: @desired_price, page_number: page_number }

      flats = Nokogiri::HTML(open("#{@base_url}#{prepared_link}")).css('.object.object--')
      break if flats.size == 0

      flats.each do |flat|
        begin
          @data << {
            title: flat.at_css('.object-title').text.strip,
            size: flat.at_css('.object-sqr').text.strip,
            address: flat.at_css('.object-address').text.strip,
            price: flat.at_css('.object-price').text.strip,
            link: flat.at_css('.object-title')['href']
          }
        rescue NoMethodError
          next
        end
      end
    end
  end
end
