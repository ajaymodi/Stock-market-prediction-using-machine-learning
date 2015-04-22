require 'rubygems'
require 'open-uri'
require 'selenium-webdriver'
require 'debugger'
require "sqlite3"
require 'net/http'
require 'JSON' 

http = Net::HTTP.new(@host, @port)
http.read_timeout = 500

   

db = SQLite3::Database.new "tweets.db"
db.busy_timeout(15000)


db.execute("CREATE TABLE IF NOT EXISTS tweets(id INTEGER PRIMARY KEY, image varchar(100), fullname varchar(100), username varchar(100), time varchar(30), tweet varchar(500), favorite int, retweet int, unique(time, username))")

# This is the same insert query we'll use for each insert statement
insert_query = "INSERT OR IGNORE INTO tweets(image, fullname, username, time, tweet, favorite, retweet) VALUES(?, ?, ?, ?, ?, ?, ?)"

# # Execute inserts with parameter markers
# db.execute("INSERT INTO students (name, email, grade, blog) 
#             VALUES (?, ?, ?, ?)", [@name, @email, @grade, @blog])

# # Find a few rows
# db.execute( "select * from numbers" ) do |row|
#   p row
# end

file = File.open("2015/6000_1.json", "r")
data = file.read
file.close

data = JSON.parse(data)
count = 0
data.each do |key|
	puts count += 1
	key["tweet"].tr!("\u00A0",'')
	key["tweet"].tr!("\n",'')
	if(key["favorite"] && key["parent"])
		db.execute(insert_query, [key["img"], key["fullname"], key["username"], key["time"], key["tweet"], key["favorite"][1].strip.to_i, key["parent"][1].strip.to_i])
	elsif(key["favorite"])
		db.execute(insert_query, [key["img"], key["fullname"], key["username"], key["time"], key["tweet"], key["favorite"][1].strip.to_i, 0])
	elsif(key["parent"])
		db.execute(insert_query, [key["img"], key["fullname"], key["username"], key["time"], key["tweet"], 0, key["parent"][1].strip.to_i])
	else
		db.execute(insert_query, [key["img"], key["fullname"], key["username"], key["time"], key["tweet"], 0, 0])
	end
end

