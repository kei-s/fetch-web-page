#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'uri'
require 'cgi'
require 'net/http'
require 'date'
require 'fileutils'
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

def save_assets(dir_name, base_url, relative_uri)
  uri = URI.parse(base_url).merge(relative_uri)
  res = Net::HTTP.get_response(uri)
  if res.is_a?(Net::HTTPSuccess)
    path = File.join(dir_name, uri.path)
    FileUtils.mkdir_p(File.expand_path('../', path))
    File.open(path, 'w') do |f|
      f.puts res.body
    end
  else
    warn "Failed to fetch #{uri}"
    warn "  Status: #{res.code}, #{res.message}"
  end
end

def save_all_assets(url)
  body = fetch_body(url)
  return unless body

  dir_name = CGI.escape(url.gsub(%r{^https?://}, ''))
  FileUtils.rm_rf(dir_name)
  Dir.mkdir(dir_name)

  file_name = URI.parse(url).normalize.path
  file_name = 'index.html' if file_name == '/'
  File.open(File.join(dir_name, file_name), 'w') do |f|
    f.puts body
  end

  doc = Nokogiri::HTML(body)
  doc.css('img', 'script').each do |tag|
    src = tag.attr('src')
    next unless src

    uri = URI.parse(src)
    save_assets(dir_name, url, uri) unless uri.absolute?
  end
  doc.css('picture source').each do |tag|
    srcset = tag.attr('srcset')
    srcset.split(',').each do |str|
      src = str.split(' ').first
      uri = URI.parse(src)
      save_assets(dir_name, url, uri) unless uri.absolute?
    end
  end
  doc.css('link').each do |tag|
    href = tag.attr('href')
    next unless href

    uri = URI.parse(href)
    save_assets(dir_name, url, uri) unless uri.absolute?
  end
end

opt = OptionParser.new
metadata = false
all_assets = false
opt.on('--metadata') { |_v| metadata = true }
opt.on('--all-assets') { |_v| all_assets = true }
urls = opt.parse(ARGV)

urls.each do |url|
  if metadata
    show_metadata(url)
  elsif all_assets
    save_all_assets(url)
  else
    save_html(url)
  end
end
