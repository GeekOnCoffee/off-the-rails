require 'uri'
require 'net/http'
require 'json'

# This is a class that can convert from USD to other currencies
class CurrencyConverter
  API_URL = URI('https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/usd.json')
  def initialize
    response = Net::HTTP.get(API_URL)
    @conversions = JSON.parse(response)
  end

  def conversion_from_usd_to(to)
    @conversions['usd'][to]
  end
end

