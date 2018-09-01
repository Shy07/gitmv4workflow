#encoding: utf-8
require 'open3'

def paste(_ = nil)
  `pbpaste`
end

def copy(data)
  Open3.popen3( 'pbcopy' ){ |input, _, _| input << data }
  paste
end

def clear
  copy ''
end

# copy ARGV[0]
#
# puts ARGV[0]
