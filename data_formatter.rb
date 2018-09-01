#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "./bundle/bundler/setup"
require "alfred"

def parse_time_stamp(ts)
  ts = ts[0..9] if ts.length === 13
  Time.at(ts.to_i)
end

def date_formate(time)
  time.strftime('%Y-%m-%d %T').to_s
end

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback
  now = Time.now
  icon = {type: 'default', name: '8BB53926-2338-4975-B29C-153ADBA3A798.png'}
  if ARGV.length == 0
    fb.add_item(
      title: now.strftime("%Y%m%d %T"),
      subtitle: '当前时间',
      icon:icon
    )
    fb.add_item(
      title: now.to_i.to_s,
      subtitle: '10位秒级时间戳',
      icon:icon
    )
    fb.add_item(
      title: (now.to_f * 1000).to_i.to_s,
      subtitle: '13位毫秒级时间戳',
      icon:icon
    )
  end

  if ARGV[0]
    case
    when ARGV[0].length == 1
      se = ARGV[0]
      fb.add_item(
        title: now.strftime("%Y#{se}%m#{se}%d %T"),
        subtitle: '当前时间',
        icon:icon
      )
    when ARGV[0] == 'cn'
      fb.add_item(
        title: now.strftime("%Y年%m月%d日"),
        subtitle: '当前日期',
        icon:icon
      )
      fb.add_item(
        title: now.strftime("%Y年%m月%d日 %T"),
        subtitle: '当前时间',
        icon:icon
      )
    when (ARGV[0].length == 10 || ARGV[0].length == 13)
      time = date_formate(parse_time_stamp(ARGV[0].to_s))
      fb.add_item(
        title: time,
        subtitle: '解析时间戳',
        icon:icon
      )
    end
  end

  puts fb.to_alfred
end
