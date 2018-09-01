#!/usr/bin/env ruby
#encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "./bundle/bundler/setup"
require "alfred"
require 'digest/md5'

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback
  content = Digest::MD5.hexdigest(ARGV[0])
  icon = 'icon.png'
  fb.add_item(
    title: content,
    subtitle: 'Copy to Clipboard',
    arg: content,
    icon: {type: 'default', name: icon}
  )

  puts fb.to_alfred
end
