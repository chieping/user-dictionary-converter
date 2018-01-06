#!/usr/bin/env ruby
require 'builder'
require 'optparse'

def gen_plist_xml(source)
  builder = Builder::XmlMarkup.new(indent: 2)
  builder.instruct!(:xml, version: '1.0', encoding: 'UTF-8')
  builder.declare!(:DOCTYPE, :plist, :PUBLIC, "-//Apple//DTD PLIST 1.0//EN", "http://www.apple.com/DTDs/PropertyList-1.0.dtd")
  builder.plist(version: '1.0') do |plist|
    plist.array do |array|
      source.each do |k, v|
        array.dict do |dict|
          dict.key("phrase")
          dict.string(v)
          dict.key("shortcut")
          dict.string(k)
        end
      end
    end
  end
end

def source_hash(source_filename)
  open(source_filename, "r").each_line.with_object({}) do |line, h|
    l = line.split("\t")
    h[l[0]] = l[1]
  end
end

def store_file(target_filename, content)
  open(target_filename, "w") { |f| f.write content }
end

def main(in_file, out_file)
  xml = gen_plist_xml(source_hash(in_file))
  store_file(out_file, xml)
end

def parse_options
  opts = {}
  opt = OptionParser.new
  opt.on('-i', '--infile FILENAME') { |v| opts['in_file'] = v }
  opt.on('-o', '--outfile FILENAME') { |v| opts['out_file'] = v }
  opt.parse!

  missing_args = ['in_file', 'out_file'].reject { |arg| opts.key? arg }
  unless missing_args.empty?
    raise OptionParser::MissingArgument, missing_args.join(', ')
  end
  opts
end

opts = parse_options
main(opts['in_file'], opts['out_file'])
