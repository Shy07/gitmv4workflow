#!/usr/bin/env ruby
#encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "./bundle/bundler/setup"
require "alfred"
require "base64"

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback
  case ARGV[0]
  when 'decode'
    content = Base64.decode64(ARGV[1])
  when 'encode'
    content = Base64.encode64(ARGV[1]).rstrip
  end
  icon = 'icon.png'
  fb.add_item(
    title: content,
    subtitle: 'Copy to Clipboard',
    arg: content,
    icon: {type: 'default', name: icon}
  )

  puts fb.to_alfred
end
