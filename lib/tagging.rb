require 'lib/tagging_extra'
require 'lib/paginate'

module Tagging

  include TaggingExtra

  # Creates in-memory tag pages
  def create_tag_pages
    tag_set(items).each do |tag|
      page_identifier = @config[:tags][:page] % tag
      next unless item_by_identifier(page_identifier).nil?
      item = Nanoc3::Item.new(
        # content
        @config[:tags][:content],
        # do not include in sitemap.xml
        { :title     => @config[:tags][:title] % tag,
          :tag       => tag,
          :page_size => 10,
          :kind      => 'tag'
        }.merge(@config[:tags][:attributes]),
        # identifier
        page_identifier,
        # options
        :binary => false
      )
      item.page_items = items_with_tag(tag, items).sort { |x, y| x[:created_at] <=> y[:created_at] }
      items << item
    end
  end

end

include Tagging

