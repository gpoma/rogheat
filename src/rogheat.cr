require "option_parser"
require "./rogheat/template/*"

# TODO: Write documentation for `Rogheat`
module Rogheat
  # TODO: Put your code here
end

template : String = ""
file : String = ""

OptionParser.parse! do |parser|
  parser.banner = "Usage: #{PROGRAM_NAME} -t|--template TEMPLATE -f|--file FILE"
  parser.on("-t TEMPLATE", "--template=template", "Type de CSV en entrée") {|type| template = type}
  parser.on("-f FILE", "--file=FILE", "Fichier csv") {|f| file = f}
  parser.on("-h", "--help", "Show this help") { puts parser }
  parser.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts parser
    exit(1)
  end
end

if template.empty? || file.empty?
  abort "Missing argument", 2
end

case template
when "rentree"
  csv = Rentree.new File.open(file), ';'
else
  abort "Unknown Template", 4
end

csv.separator = ';'
csv.quote = '"'
csv.check
csv.generate
