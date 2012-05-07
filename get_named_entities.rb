require 'rubygems'
require 'nokogiri'
require 'hpricot'
require 'socket'
require 'open-uri'
require 'active_support/inflector'

ENTITIES = []
entities = File.open('ENTITIES').read
entities.each_line {|line|
  ENTITIES.push line.gsub(/\n/, '')
}

if ARGV.length != 1
  data_url = "http://mblongii.com"
else
  data_url = ARGV[0]
end

def retrieve_data(url)
  doc = Nokogiri::HTML( open(url) )
  doc.css('title','p','li','a').text
end

def get_named_entities(url)
  client = TCPSocket.open('localhost', 8080)
  client.puts(retrieve_data(url))
  ner_data = ""
  while line = client.gets
    ner_data += line
  end
  client.close_read
  for feature in ENTITIES
    entities = Hpricot(ner_data)
    output = []
    (entities/feature).each do |f|
      output.push f.inner_text
    end
    if output.size > 0
      puts "#{feature.to_s.pluralize.swapcase}:"
      output.each {|e| puts "\t#{e}"}
    end
  end
end

get_named_entities(data_url)
