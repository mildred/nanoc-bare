
class Nanoc3::Item
  attr_accessor :page_items
  
  def paginated?
    not page_items.empty?
  end
end

module Paginate
  
  def paginated_items(items)
    items.select { |i| i.paginated? }
  end
  
  def create_pages
    page_size = 10
    page_layout = "_pagination"
    paginated_items(items).each do |item|
      groups = []
      elements = item.page_items
      
      # Group items into pages
      until elements.size <= page_size
        groups << elements.slice!(-page_size..-1)
      end
      
      groups.each_with_index do |group, i|
        first = i*page_size
        last  = first + subarticles.size
        pages = group

        items << Nanoc3::Item.new(
          "= render('#{page_layout}', :page => #{i+1}, :first => #{first}, :last => #{last}, :page_num => #{groups.size})",
          { :title => "Items %d to %d" % [first + 1, last] },
          "%s%d/" % [item.path, i+1])
      end
    end
  end
  
end

include Paginate

def paginate_articles
  articles_to_paginate = sorted_articles

  article_groups = []
  until articles_to_paginate.size <= @config[:articles][:page][:size]
    article_groups << articles_to_paginate.slice!(-@config[:articles][:page][:size]..-1)
  end
  article_groups << articles_to_paginate

  article_groups.each_with_index do |subarticles, i|
    first = i*@config[:articles][:page][:size]
    last  = first + subarticles.size
    pages = subarticles

    @items << Nanoc3::Item.new(
      "= render('#{@config[:articles][:page][:layout]}', :page => #{i+1}, :first => #{first}, :last => #{last}, :page_num => #{article_groups.size})",
      { :title => @config[:articles][:page][:title] % [first + 1, last] },
      @config[:articles][:page][:url] % [i+1]
    )
  end
  
  size = sorted_articles.size
  first = size-@config[:articles][:index][:size]
  last = size-1
  @items << Nanoc3::Item.new(
    "= render('#{@config[:articles][:index][:layout]}', :page => nil, :first => #{first}, :last => #{last}, :page_num => #{article_groups.size})",
    { :title => @config[:articles][:index][:title]},
    @config[:articles][:index][:url]
  )

end

