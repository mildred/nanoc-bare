require 'nanoc3/tasks'
require 'fileutils'

namespace :create do

  desc "Creates a new article"
  task :article do
    $KCODE = 'UTF8'
    #require 'active_support/core_ext'
    #require 'active_support/multibyte'
    @ymd = Time.now.strftime("%Y-%m-%d")
    @datetime = Time.now.strftime("%F %T %z").gsub(/([0-2][0-9])([0-6][0-9])$/, "\\1:\\2")
    if !ENV['title']
      $stderr.puts "\t[error] Missing title argument.\n\tusage: rake create:article title='article title'"
      exit 1
    end

    title = ENV['title'].capitalize
    path, filename, full_path = calc_path(title)

    if File.exists?(full_path)
      $stderr.puts "\t[error] Exists #{full_path}"
      exit 1
    end

    template = <<TEMPLATE
---
title:      #{title}
created_at: #{@datetime}
excerpt:
author:     #{`whoami`.capitalize}
kind:       article
publish:    true
tags:
  - misc
---

TODO: Add content to `#{full_path}.`
TEMPLATE

    FileUtils.mkdir_p(path) if !File.exists?(path)
    File.open(full_path, 'w') { |f| f.write(template) }
    $stdout.puts "\t[ok] Edit #{full_path}"
  end

  def calc_path(title)
    #year, month_day = @ymd.split('-', 2)
    path = "content/articles/"
    filename = @ymd + "-" + title.tr("A-Z", "a-z").gsub(/[^a-z0-9_-]+/, '_').gsub(/^_*/, "").gsub(/_*$/, "") + ".md"
    [path, filename, path + filename]
  end
end

