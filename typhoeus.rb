# frozen_string_literal: true

require 'typhoeus'

Typhoeus::Config.verbose = true

hydra = Typhoeus::Hydra.new(max_concurrency: 20)

first_request = Typhoeus::Request.new(
  'www.example.com',
  method: :post,
  body: 'this is a request body',
  params: { field1: 'a field' },
  headers: { Accept: 'text/html' }
)

first_request.on_complete do |response|
  if response.success?
    puts 'hell yeah'
  elsif response.timed_out?
    puts 'aw hell no'
    puts 'got a time out'
  else
    # Received a non-successful http response.
    puts "HTTP request failed: #{response.code}"
  end
end

first_request.on_complete do |response|
  third_url = response.body
  third_request = Typhoeus::Request.new(third_url)
  hydra.queue third_request
end
second_request = Typhoeus::Request.new('http://example.com/posts/2')

hydra.queue first_request
hydra.queue second_request
hydra.run # this is a blocking call that returns once all requests are complete
