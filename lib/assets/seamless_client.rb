class SeamlessClient
  include Wombat::Crawler
  # def initialize(path="/food-delivery/empire-biscuit-new-york-city.34474.r?cm_sp=Consumer-Step-1-_-Order-History-_-Restaurant-Menu")
  #   self.class.path path
  # end
  base_url "http://www.seamless.com"
  path "/food-delivery/empire-biscuit-new-york-city.34474.r?cm_sp=Consumer-Step-1-_-Order-History-_-Restaurant-Menu"
  phone_number :css, "p#RestaurantAddress span"
end
