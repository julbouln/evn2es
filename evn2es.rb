#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)

require 'set'
require 'fileutils'
require 'bindata'
require 'resourcefork'

require 'evn_to_es'
require 'rle'

require 'optparse'

@bin = false
@output = "evn"
@converter = nil
@verbose = false
@clean = false
@patched = false

["sox", "lame", "convert"].each do |cmd|
  unless system("which #{cmd} > /dev/null")
    puts "Required program is missing: #{cmd}"
  end
end

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: evn2es.rb [options]"

  opts.separator "Options :"
  opts.on('-h', '--help', 'Displays this help') do
    puts opts
    exit
  end
  opts.on('-v', '--verbose', 'Verbose') do |opt|
    @verbose = opt
  end

  opts.separator "Main options :"
  opts.on("-i", "--input DIR", "EVN data files directory (required)") do |opt|
    @input = opt
  end
  opts.on("-o", "--output DIR", "ES output directory") do |opt|
    @output = opt
  end
  opts.separator "Extra options :"
  opts.on("-c", "--converter CONVERTER", "Only apply this converter") do |opt|
    @converter = opt
  end
  opts.on("-x", "--clean", "Clean output instead of converting") do |opt|
    @clean = opt
  end
  opts.on("-p", "--patched", "Use patched Endless Sky version") do |opt|
    @patched = opt
  end
  opts.on("-b", "--bin", "Parse .bin files instead of .ndat") do |opt|
    @bin = opt
  end
end
optparse.parse!

if !@input
  puts "Error: input directory required"
  puts optparse
  exit
end

files = []
if @bin
  unless system("which macunpack > /dev/null")
    puts "Required program is missing: macunpack"
  end

  files = Dir.glob("#{@input}/*.bin")
  files.each do |f|
    system("cd \"#{File.dirname(f)}\";macunpack -r \"#{File.basename(f)}\"")
  end
  files = Dir.glob("#{@input}/*.rsrc")
else
  files = Dir.glob("#{@input}/*.ndat")
end

conv = EvnToEs::Convert.new(@output, @verbose, @patched)
if @clean
  puts "Cleaning ..."
  conv.clean(files, @converter)
else
  puts "Converting ... this can take several minutes"
  conv.convert(files, @converter)
end


