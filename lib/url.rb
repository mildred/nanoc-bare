include Nanoc3::Helpers::LinkTo
# relative_path_to

def absolute_url(item)
  @config[:base_url] + item.path
end

def link_path(path)
  relative_path_to(path)
end

def link_item(identifier_or_item)
  relative_path_to(route_path(identifier_or_item))
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
