require 'lib/tagging_extra'
require 'lib/paginate'

module Tagging

  include TaggingExtra

  # Creates in-memory tag pages
  def create_tag_pages
    tag_set(items).each do |tag|
      item = Nanoc3::Item.new(
        # content
        @config[:tags][:content],
        # do not include in sitemap.xml
        { :title     => @config[:tags][:title] % tag,
          :tag       => tag,
          :page_size => 10,
          :kind      => 'tag'},
        # identifier
        @config[:tags][:page] % tag,
        # options
        :binary => false
      )
      item.page_items = items_with_tag(tag, items).sort { |x, y| x[:created_at] <=> y[:created_at] }
      items << item
    end
  end

end

include Tagging

