#!/usr/bin/env ruby
#encoding: utf-8
require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8
require "./bundle/bundler/setup"
require "alfred"
require 'nokogiri'
require 'net/http'
require 'json'
require 'bigdecimal'

code = open('currency.json', 'rb') {|io| io.read }
CURRENCIES = JSON.parse code

BOCAPI = URI 'http://srh.bankofchina.com/search/whpj/search.jsp'
PJNAME = {
  '澳大利亚元' => '1325',
  '英镑' => '1314',
  '加拿大元' => '1324',
  '欧元' => '1326',
  '港币' => '1315',
  '日元' => '1323',
  '美元' => '1316',
  '瑞士法郎' => '1317'
}

def response_body(pjname)
  body = ''
  today = Time.new.strftime("%Y-%m-%d")
  Net::HTTP.start(BOCAPI.host, BOCAPI.port) do |http|
    request = Net::HTTP::Post.new BOCAPI
    request.set_form_data('erectDate' => today,
                          'nothing' => today,
                          'pjname' => pjname)
    response = http.request request
    body = response.body
  end
  body
end

def rate_from(res)
  html = Nokogiri::HTML res.force_encoding(Encoding::UTF_8).gsub(/\t|\r|\n|/, '')
  table = Nokogiri::HTML html.css('.BOC_main table').to_html
  rate_text = table.css('tr td')[2].text
  num = BigDecimal.new(rate_text)
  raise 'err' unless num.is_a? Numeric
  rate = num.frac == 0 ? num.to_i : num.to_f
  rate / 100.0
end

def update_currency
  today = Time.new.strftime("%Y-%m-%d-%H")
  if CURRENCIES['updated_at'] != today
    PJNAME.each do |key, value|
      res = response_body value
      rate = rate_from res
      short, data = CURRENCIES.find {|k, v| v['cname'] == key }
      data['rate'] = rate
      CURRENCIES['updated_at'] = today
    end
    open('currency.json', 'wb') {|io| io.write CURRENCIES.to_json }
  end
end

def exchange_rate_from(src, val, des)
  num = BigDecimal.new(val.to_s.gsub(',', ''))
  raise 'err' unless num.is_a? Numeric
  src_value = num.frac == 0 ? num.to_i : num.to_f

  src_currency = CURRENCIES[src] && CURRENCIES[src]['rate']
  raise 'err' unless src_currency.is_a? Numeric
  rmb_value = src_value * src_currency

  des_currency = CURRENCIES[des] && CURRENCIES[des]['rate']
  raise 'err' unless des_currency.is_a? Numeric
  des_value = rmb_value / des_currency
  "#{CURRENCIES[des]['symbol']} #{"%0.02f" % des_value}"
end

CURS = %w{CNY JPY USD GBP EUR HKD AUD CAD CHF}

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback
  update_currency
  content = exchange_rate_from(ARGV[0], ARGV[1], 'CNY')
  icon = 'icon.png'
  src = ARGV[0].upcase
  CURS.reverse.find_all{|x| x != src }.each do |des|
    fb.add_item(
      title: exchange_rate_from(src, ARGV[1], des),
      subtitle: "#{CURRENCIES[src]['cname']}兑#{CURRENCIES[des]['cname']}汇率 (#{src} to #{des})",
      icon: {type: 'default', name: icon}
    )
  end

  puts fb.to_alfred
end
