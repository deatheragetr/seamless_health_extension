require 'httparty'

empty_response_returned = false
iteration = 0
until empty_response_returned
  puts iteration
  iteration += 1
  Thread.new do
    response = HTTParty.get('http://data.cityofnewyork.us/resource/xx67-kt59.json')
    if response.empty? || response.code != 200
      puts "EMPTY RESPONSE RETRIEVEDDDDD OR NON 200"
      empty_response_returned = true
    end
  end
end
