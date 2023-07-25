require './currency_class'

converter = CurrencyConverter.new

puts converter.conversion_from_usd_to('eur')
