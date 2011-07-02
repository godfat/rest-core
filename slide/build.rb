#!/usr/bin/env ruby

require 'nokogiri'

cmd = 'landslide -t themes --embed slide.md'
puts(cmd)
system(cmd)
slide = Nokogiri::HTML.parse(File.read('presentation.html'))

# strip full path
slide.css('.source a').each{ |n| n['href'] = n.inner_text }

# strip title
title = slide.css('title').first
title.content = title.children.reject{ |e|
                  e.element? && e.children.empty? }.join("\u{2014}")

File.open('slide.html', 'w'){ |f| f.puts slide.to_html }
