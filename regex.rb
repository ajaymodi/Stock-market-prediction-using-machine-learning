require 'csv'
require 'debugger'

CSV.open("file.csv", "wb") do |abc|
	CSV.foreach("Tweets.csv") do |row|
		temp = row
		row = row[0]

		puts row = row.gsub( /\s+/, " " ) 
		puts row = row.gsub(/https?:\/\/[\S]+/, "")
		puts row = row.gsub(/[#@$]\w+/, '') 
		puts row = row.gsub(/pic.twitter.com\/[\S]+/, "") 
  		puts row = row.gsub("?", "")
		puts row = row.gsub("=", "")
		puts row = row.tr(" '\"", "")
		puts row = row.gsub("*", "")
		puts row = row.gsub("+", "")
		puts row = row.gsub("-", "")
		puts row = row.gsub("%", "")
  		temp[0] = row
  		abc << temp
	end
end
