require 'open-uri'

class SeamlessClient
  attr_reader :seamless_base, :path, :show_page
  def initialize(path)
    @seamless_base = "http://www.seamless.com/food-delivery"
    @path          = path
    @show_page     = Nokogiri::HTML(open(seamless_base + path))
  end

  def phone
    telement = show_page.css("p#RestaurantAddress span").to_a.keep_if { |span| span.values.include? "telephone" }.first
    unless telement.blank?
      telement.children.first.inner_text.gsub(/[\s+|\(|\)|-]/, "")
    end
  end
end
