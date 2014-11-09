# class SeamlessClient
#   include Wombat::Crawler
#   # def initialize(path="/food-delivery/empire-biscuit-new-york-city.34474.r?cm_sp=Consumer-Step-1-_-Order-History-_-Restaurant-Menu")
#   #   self.class.path path
#   # end
#   base_url "http://www.seamless.com"
#   path "/food-delivery/empire-biscuit-new-york-city.34474.r?cm_sp=Consumer-Step-1-_-Order-History-_-Restaurant-Menu"
#   phone_number :css, "p#RestaurantAddress span"
# end
require 'open-uri'
class SeamlessClient
  attr_reader :seamless_base, :path, :show_page
  def initialize(path)
    @seamless_base = "http://www.seamless.com"
    @path          = path
    @show_page     = Nokogiri::HTML(open(seamless_base + path))
  end

  def telephone
    spans = show_page.css("p#RestaurantAddress span")
    spans.to_a.keep_if {|span| span.values.include? "telephone" } \
      .first.children.first.inner_text \
      .gsub(/[\s+|\(|\)|-]/, "")
  end
end
