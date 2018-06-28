require "./rogheat/template/*"

# TODO: Write documentation for `Rogheat`
module Rogheat
  # TODO: Put your code here
end

csv = Rentree.new File.open("/home/gabriel/Documents/Cocktail/Rentrée/TEMPLATE_FICHIER_SOURCE.csv"), ';'
csv.separator = ';'
csv.quote = '"'
csv.check
csv.generate
