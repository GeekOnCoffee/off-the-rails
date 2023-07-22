# Super easy procedural example

require 'uri'
require 'net/http'
require 'json'

uri = URI('https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/usd.json')
response = Net::HTTP.get(uri)
conversions = JSON.parse(response)

puts conversions["usd"]["eur"]
