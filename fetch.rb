#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'uri'
require 'cgi'
require 'net/http'
require 'date'
require 'nokogiri'

def fetch_body(url)
  res = Net::HTTP.get_response(URI.parse(url))
  if res.is_a?(Net::HTTPSuccess)
    res.body
  else
    warn "Failed to fetch #{url}"
    warn "  Status: #{res.code}, #{res.message}"
  end
rescue StandardError => e
  warn "Failed to fetch #{url}"
  warn "  Error: #{e.message}"
end

def save_html(url)
  body = fetch_body(url)
  return unless body

  file_name = "#{CGI.escape(url.gsub(%r{^https?://}, ''))}.html"
  File.open(file_name, 'w') do |f|
    f.puts body
  end
end

def show_metadata(url)
  body = fetch_body(url)
  return unless body

  doc = Nokogiri::HTML(body)
  puts "Site: #{url.gsub(%r{^https?://}, '')}"
  puts "num_links: #{doc.css('a').size}"
  puts "images: #{doc.css('img').size}"
  puts "last_fetch: #{DateTime.now}"
end

opt = OptionParser.new
metadata = false
opt.on('--metadata') {|v| metadata = true }
urls = opt.parse(ARGV)

urls.each do |url|
  if metadata
    show_metadata(url)
  else
    save_html(url)
  end
end
