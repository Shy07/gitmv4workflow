#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "./bundle/bundler/setup"

require 'digest/md5'
require 'qrcoder'

module QRCode
  #
  # =>
  #
  CACHE_PATH = './cache'
  QRCODE_PATH = CACHE_PATH + '/qrcode'
  [CACHE_PATH, QRCODE_PATH].each do |dir|
    unless File.exist? dir; begin; Dir.mkdir dir; rescue; puts 'error'; end; end
  end
  #
  # =>
  #
  module_function
  #
  # =>
  #
  def generate string_data
    @key = Digest::MD5.hexdigest string_data
    @qr_filepath = "#{QRCODE_PATH}/#{@key}.svg"
    unless File.exist? @qr_filepath
      result = qrcode_data string_data
      # open(@qr_filepath, 'wb') {|io| io.write result }
    end
    @qr_filepath
    # system "open #{@qr_filepath} -a '#{AI_PATH}'"
  end
  #
  # =>
  #
  def qrcode_data(text)
    QRCoder::QRCode.image text, QRCODE_PATH, :format => [:svg],\
                          :filename => @key, :size => 5
  end
end

# open('test.log', 'a') {|io| io.write ARGV[0]+"\n" }
system "open #{QRCode.generate ARGV[0]} -a '#{ARGV[1]}'"
