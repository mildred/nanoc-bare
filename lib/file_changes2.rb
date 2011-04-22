

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

