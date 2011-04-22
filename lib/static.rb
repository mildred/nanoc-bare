
module Static

  # Copy static assets outside of content instead of having nanoc3 process them.
  def copy_static
    system "rsync -a --exclude=.git --exclude='*~' --delete-excluded static/. output/"
  end

end

include Static
