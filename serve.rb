#!/usr/bin/env ruby
require 'optparse'
require 'webrick'

opt = OptionParser.new
https = false
opt.on('--https') {|_v| https = true }
dir_name = opt.parse(ARGV).first

if https
  require 'webrick/https'
  WEBrick::HTTPServer.new(:DocumentRoot => "./#{dir_name}", :Port => 8000,
     :SSLEnable => true, :SSLCertName => [["CN", WEBrick::Utils::getservername]] ).start
else
  WEBrick::HTTPServer.new(:DocumentRoot => "./#{dir_name}", :Port => 8000).start
end
