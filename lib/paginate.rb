
class Nanoc3::Item
  attr_accessor :page_items
  attr_accessor :page_parent
  attr_accessor :sub_pages
  
  def paginated?
    not page_items.nil? and not page_items.empty? and page_parent.nil?
  end
end

module Paginate
  
  def paginated_items(items)
    items.select { |i| i.paginated? }
  end
  
  def create_pages
    paginated_items(items).each do |item|
      page_size = item[:page_size] or 10
      groups = []
      elements = Array.new(item.page_items)
      item.sub_pages = []
      
      # Group items into pages
      until elements.size <= page_size
        groups << elements.shift(page_size)
      end
      groups << elements
      
      groups.each_with_index do |group, i|
        first = i*page_size
        last  = first + group.size - 1

        it = Nanoc3::Item.new(
          item.raw_content,
          item.attributes.merge({
           :paginate   => true,
           :page       => i + 1,
           :first_item => first,
           :last_item  => last,
           :num_pages  => groups.size}),
          "%s%d/" % [item.identifier, i+1])
        it.page_items = group
        it.page_parent = item
        item.sub_pages[i+1] = it
        items << it
      end
      item[:num_pages] = groups.size
      item[:paginate] = false
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

