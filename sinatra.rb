require 'sinatra'
require './currency_class'
get '/currency/:to\.?:format?' do |to, format|
  if format == 'json'
    {to => CurrencyConverter.new.conversion_from_usd_to(to)}.to_json
  else
    "$1 USD = #{CurrencyConverter.new.conversion_from_usd_to(to)} #{to.upcase}"
  end
end

