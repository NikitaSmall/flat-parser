require 'nokogiri'

require_relative './base_parser'

class PresidentParser < BaseParser
  LINKS = [
    '/search/b:&tid=s_s&db=0&etag1=2&cena2=%{desired_price}' \
    '&val=2&rg=1&sort=0&vv=g&?page=%{page_number}'
  ].freeze

  def collect
    LINKS.each { |link| collect_from_page(link) }
  end

  def filter
    @logger.info("Flats before filter: #{@data.length}")

    @data.select! { |flat| flat[:title] != 'Коммунальная' }
    @data.select! { |flat| @whitelist.any? { |whiteflat| flat[:address].include?(whiteflat) } }

    @data.select! do |flat|
      distance(@init_position, flat[:address]) < @desired_distance
    end

    @logger.info("Flats after filter: #{@data.length}")
  end

  private

  def collect_from_page(link)
    1.step do |page_number|
      prepared_link = link % { desired_price: @desired_price, page_number: page_number }

      flats = Nokogiri::HTML(open("#{@base_url}#{prepared_link}"), nil, 'utf-8').css('div a:nth-child(3)')
      break if flats.size == 0

      flats.each do |flat|
        begin
          @data << {
            title: flat.at_css('div div:nth-child(2) div:nth-child(1)').text.strip,
            size: flat.at_css('div div:nth-child(2) div:nth-child(4)').text.strip,
            address: flat.at_css('div div:nth-child(2) div:nth-child(2)').text.strip,
            price: flat.at_css('div div:nth-child(2) div:nth-child(6)').text.split('/')[1].strip,
            link: flat['href']
          }
        rescue NoMethodError
          next
        end
      end
    end
  end
end
