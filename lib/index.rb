
module Index

  def items_of_kind(kind, items)
    items.select { |i| i[:kind] == kind }
  end

  def create_index
    all_index = items.select { |i| not i[:index_kind].nil? }
    all_index.each do |index|
      index.page_items = items_of_kind(index[:index_kind], items).sort { |x, y| x[:created_at] <=> y[:created_at] }
    end
  end

end

include Index

