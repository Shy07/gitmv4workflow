#!/usr/bin/env ruby
#encoding: utf-8

require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "./bundle/bundler/setup"
require "alfred"

class String
  NUMBER = %{零壹贰叁肆伍陆柒捌玖}

  def make_cny(result, i, idx)
    fix = %{亿万元分}[idx]
    if i > 0 || idx == 3
      result += "#{NUMBER[i / 10000]}万" if i >= 10000
      i %= 10000
      result += "#{NUMBER[i / 1000]}仟" if i >= 1000
      i %= 1000
      result += "#{NUMBER[i / 100]}佰" if i >= 100
      result += '零' if i < 100 && result.length > 0 && idx != 3
      i %= 100
      if i.between?(1, 9)
        result += "#{result.length > 0 ? '零' : ''}#{NUMBER[i % 10]}"
      elsif i >= 10
        result += "#{NUMBER[i / 10]}#{idx == 3 ? '角': '拾'}#{NUMBER[i % 10]}"
      end
      result += result.length > 0 ? fix : ''
      result.gsub!('零零', '零') while result.include? '零零'
      result = result.gsub("零#{fix}", fix)
        .gsub('元分', '元整')
        .gsub('角分', '角整')
        .gsub(/^元/, '')
    end
    result += '元' if idx == 2 && !(result.include? '元')
    result
  end

  def to_cny
    return '零元整' if ['0', '.', '0.'].include? self
    result = ''
    ("%015.02f" % self.gsub(',', '').to_f)
    .scan(/^(\d*)(\d{4})(\d{4})\.(\d{2})$/)
    .flatten.each_with_index do |s, idx|
      i = s.to_i
      return 'You are toooooo rich!' if i >= 100000
      result = make_cny result, i, idx
    end
    result
  end
end

# test_data = {
#   '.1' => '壹角整',
#   '0.1' => '壹角整',
#   '0' => '零元整',
#   '1' => '壹元整',
#   '10' => '壹拾元整',
#   '100' => '壹佰元整',
#   '1000' => '壹仟元整',
#   '10000' => '壹万元整',
#   '100000' => '壹拾万元整',
#   '1000000' => '壹佰万元整',
#   '10000000' => '壹仟万元整',
#   '100000000' => '壹亿元整',
#   '1000000000' => '壹拾亿元整',
#   '10000000000' => '壹佰亿元整',
#   '100000000000' => '壹仟亿元整',
#   '1000000000000' => '壹万亿元整',
#   '21.09' => '贰拾壹元零玖分',
#   '301.1' => '叁佰零壹元壹角整',
#   '321.1' => '叁佰贰拾壹元壹角整',
#   '2321.1' => '贰仟叁佰贰拾壹元壹角整',
#   '2021.1' => '贰仟零贰拾壹元壹角整',
#   '2001.1' => '贰仟零壹元壹角整',
#   '42321.1' => '肆万贰仟叁佰贰拾壹元壹角整',
#   '642321.1' => '陆拾肆万贰仟叁佰贰拾壹元壹角整',
#   '602321.1' => '陆拾万贰仟叁佰贰拾壹元壹角整',
#   '7642321.1' => '柒佰陆拾肆万贰仟叁佰贰拾壹元壹角整',
#   '7602321.1' => '柒佰陆拾万贰仟叁佰贰拾壹元壹角整',
#   '7002321.1' => '柒佰万贰仟叁佰贰拾壹元壹角整',
#   '87642321.1' => '捌仟柒佰陆拾肆万贰仟叁佰贰拾壹元壹角整',
#   '987642321.12' => '玖亿捌仟柒佰陆拾肆万贰仟叁佰贰拾壹元壹角贰分',
#   '1987642321.12' => '壹拾玖亿捌仟柒佰陆拾肆万贰仟叁佰贰拾壹元壹角贰分',
#   '21987642321.12' => '贰佰壹拾玖亿捌仟柒佰陆拾肆万贰仟叁佰贰拾壹元壹角贰分',
#   '321987642321.12' => '叁仟贰佰壹拾玖亿捌仟柒佰陆拾肆万贰仟叁佰贰拾壹元壹角贰分',
#   '4321987642321.12' => '肆万叁仟贰佰壹拾玖亿捌仟柒佰陆拾肆万贰仟叁佰贰拾壹元壹角贰分',
#   '54321987642321.12' => '...',
# }

# test_data.each do |k, v|
#   r = k.to_cny
#   print r == v ? "ok\n" : "#{r} should be\n#{v}(#{k})\n"
# end

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback
  content = ARGV[0].to_cny
  icon = 'icon.png'
  fb.add_item(
    title: content,
    subtitle: 'Copy to Clipboard',
    arg: content,
    icon: {type: 'default', name: icon}
  )

  puts fb.to_alfred
end
