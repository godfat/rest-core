#!/usr/bin/env ruby

require 'nokogiri'

def sh cmd
  puts cmd
  system(cmd)
end

sh('landslide -t theme --embed slide.md')
slide = Nokogiri::HTML.parse(File.read('presentation.html'))
sh('rm presentation.html')

# strip full path
slide.css('.source a').each{ |n| n['href'] = n.inner_text }

# strip title
title = slide.css('title').first
title.content = title.children.reject{ |e|
                  e.element? && e.children.empty? }.join("\u{2014}")

File.open('slide.html', 'w'){ |f| f.puts slide.to_html }
puts("Created slide.html")
