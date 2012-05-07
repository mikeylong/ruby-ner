require 'rubygems'
require 'nokogiri'
require 'hpricot'
require 'socket'
require 'open-uri'
require 'active_support/inflector'

ENTITIES = []
entities = File.open('ENTITIES').read
entities.each_line {|line|
  ENTITIES.push line.strip
}

if ARGV.length != 1
  url = "http://mblongii.com"
else
  url = ARGV[0]
end

def retrieve_data(url)
  doc = Nokogiri::HTML( open(url) )
  doc.css('p','li').text
end

def get_named_entities(url)
  client = TCPSocket.open('localhost', 8080)
  client.puts( retrieve_data(url) )
  ner_response = ""
  while line = client.gets
    ner_response += line
  end
  client.close_read
  for type in ENTITIES
    tagged_entities = Hpricot(ner_response)
    output = []
    (tagged_entities/type).each do |f|
      output.push f.inner_text
    end
    if output.size > 0
      puts "#{type.to_s.pluralize.swapcase}:"
      output.each {|e| puts "\t#{e}"}
    end
  end
end

get_named_entities(url)
