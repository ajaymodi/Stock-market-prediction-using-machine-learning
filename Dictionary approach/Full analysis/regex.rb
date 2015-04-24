require 'csv'
require 'debugger'

CSV.open("file.csv", "wb") do |abc|
	CSV.foreach("Tweets.csv") do |row|
		temp = row
		row = row[0]

		row = row.gsub( /\s+/, " " ) 
		row = row.gsub(/https?:\/\/[\S]+/, "")
		row = row.gsub(/[#@$]\w+/, '') 
		row = row.gsub(/pic.twitter.com\/[\S]+/, "") 
  		row = row.gsub("?", "")
		row = row.gsub("=", "")
		row = row.gsub(":", "")		
		row = row.gsub("*", "")
		row = row.gsub("+", "")
		row = row.gsub("-", "")
		row = row.gsub("%", "")
  		temp[0] = row
  		abc << temp
	end
end
