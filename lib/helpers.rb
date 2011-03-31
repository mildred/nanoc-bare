include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::XMLSitemap
include Nanoc3::Helpers::LinkTo
require 'builder'
require 'fileutils'
require 'time'

def link_path(path)
  relative_path_to(path)
end

def link_item(identifier_or_item)
  relative_path_to(route_path(identifier_or_item))
end

def tags(items=nil)
  count_tags(items).sort_by{|k,v| k}.map{ |x| x[0] }
end

# Hyphens are converted to sub-directories in the output folder.
#
# If a file has two extensions like Rails naming conventions, then the first extension
# is used as part of the output file.
#
# sitemap.xml.erb # => sitemap.xml
#
# If the output file does not end with an .html extension, item[:layout] is set to 'none'
# bypassing the use of layouts.
#
def route_path(identifier_or_item)
  item = identifier_or_item.is_a?(Nanoc3::Item) ? identifier_or_item : item_by_identifier(identifier_or_item)
  if item.reps.empty? then
    raise Exception, "Cannot link to #{reps.identifier}. No representation generated."
  else
    item.reps[0].path
  end
end

# Creates in-memory tag pages from partial: layouts/_tag_page.haml
def create_tag_pages
  tag_set(items).each do |tag|
    items << Nanoc3::Item.new(
      # haml content
      "= render('#{@config[:tags][:layout]}', :tag => '#{tag}')",
      # do not include in sitemap.xml
      { :title => @config[:tags][:title] % tag, :is_hidden => true},
      # identifier
      @config[:tags][:page] % tag,
      # options
      :binary => false
    )
  end
end


def add_update_item_attributes
  changes = MGutz::FileChanges.new

  items.each do |item|
    if item[:kind] == "article"
      # filename might contain the created_at date
      item[:created_at] ||= derive_created_at(item)
      # sometimes nanoc3 stores created_at as Date instead of String causing a bunch of issues
      item[:created_at] = item[:created_at].to_s if item[:created_at].is_a?(Date)

      # sets updated_at based on content change date not file time
      change = changes.status(item[:content_filename], item[:created_at], item.raw_content)
      item[:updated_at] = change[:updated_at].to_s
    end
  end
end


def paginate_articles
  articles_to_paginate = sorted_articles

  article_groups = []
  until articles_to_paginate.empty?
    article_groups << articles_to_paginate.slice!(0..@config[:articles][:page][:size]-1)
  end

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

end


def partial(identifier_or_item)
  item = identifier_or_item.is_a?(Nanoc3::Item) ? identifier_or_item : item_by_identifier(identifier_or_item)
  item.compiled_content(:snapshot => :pre)
end

def item_by_identifier(identifier)
  items ||= @items
  items.find { |item| item.identifier == identifier }
end

#=> { 2010 => { 12 => [item0, item1], 3 => [item0, item2]}, 2009 => {12 => [...]}}
def articles_by_year_month
  result = {}
  current_year = current_month = year_h = month_a = nil

  sorted_articles.each do |item|
    d = Date.parse(item[:created_at])
    if current_year != d.year
      current_month = nil
      current_year = d.year
      year_h = result[current_year] = {}
    end

    if current_month != d.month
      current_month = d.month
      month_a = year_h[current_month] = []
    end

    month_a << item
  end

  result
end

def is_front_page?
    @item.identifier == '/'
end


def n_newer_articles(n, reference_item)
  @sorted_articles ||= sorted_articles
  index = @sorted_articles.index(reference_item)
  
  # n = 3, index = 4
  if index >= n
    @sorted_articles[index - n, n]
  elsif index == 0
    []
  else # index < n
    @sorted_articles[0, index]
  end
end


def n_older_articles(n, reference_item)
  @sorted_articles ||= sorted_articles
  index = @sorted_articles.index(reference_item)
  
  # n = 3, index = 4, length = 6
  length = @sorted_articles.length
  if index < length
    @sorted_articles[index + 1, n]
  else
    []
  end
end


def site_name
  @config[:site_name]
end

def pretty_time(time)
  Time.parse(time).strftime("%b %d, %Y") if !time.nil?
end

def featured_count
  @config[:featured_count].to_i
end

def excerpt_count
  @config[:excerpt_count].to_i
end

def to_month_s(month)
  Date.new(2010, month).strftime("%B")
end

private

def derive_created_at(item)
  parts = item.identifier.gsub('-', '/').split('/')[1,3]
  date = '1980/1/1'
  begin
    Date.strptime(parts.join('/'), "%Y/%m/%d")
    date = parts.join('/')
  rescue
  end
  date
end
