class BaseParser
  def initialize(base_url, price = 50000, distance = 8000)
    @base_url = base_url
    @data = []

    @desired_price = price
    @desired_distance = distance
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
end
