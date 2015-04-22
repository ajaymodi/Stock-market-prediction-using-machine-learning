require 'rubygems'
require 'open-uri'
require 'selenium-webdriver'
require 'debugger'
require "sqlite3"
require 'net/http' 

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
(Date.new(2014, 6, 04)..Date.new(2014, 12, 20)).each do |date|
	startdate = date
	enddate = date+1
	url = "https://twitter.com/search?f=realtime&q=%24SPX%20since%3A#{startdate}%20until%3A#{enddate}&src=typd"
	puts url
	driver = Selenium::WebDriver.for :firefox
	driver.get(url)

	until driver.execute_script("return $('.content').length") > 0
	  sleep(1)
	end
	puts driver.find_elements(:css, '.content').length

	driver.execute_script("window.getTweets = function () {
			tweets = document.querySelectorAll('.js-stream-tweet .content') || document.querySelectorAll('.timeline');
			parsedTweets = [];
			 
			Array.prototype.forEach.call(tweets, function (tweet) {  
			  if (tweet.querySelector('.js-action-profile-promoted')) {
				return 0;
			  }

			  if(tweet.querySelector('.avatar') && $(tweet.querySelector('.fullname')) && $(tweet.querySelector('.username')) && tweet.querySelector('._timestamp') && $(tweet.querySelector('.tweet-text'))) {
				  var img = tweet.querySelector('.avatar').getAttribute('src'),	  
					  fullname = $(tweet.querySelector('.fullname')).text(),
					  username = $(tweet.querySelector('.username')).text(),
					  time = tweet.querySelector('._timestamp').getAttribute('data-time'),
					  twit = $(tweet.querySelector('.tweet-text')).text();
					
				  parsedTweets.push({
					'img': img,
					'fullname': fullname,
					'username': username,
					'time': time,
					'tweet': twit,
					'parent': $(tweet).parent().html()
				  });
				}
			});
	}")

	#f.execute_script("window.blah = function () {document.body.innerHTML='testing';}")
	driver.execute_script("getTweets()")
	a = driver.execute_script("return parsedTweets")
	a.each do |key|
		temp = key["parent"].scan(/ProfileTweet-actionCountForA.*/)
		key["favorite"]=temp[1].split('>')[1].split(' ')[0]
		key["retweet"]=temp[0].split('>')[1].split(' ')[0]
		key["tweet"].tr!("\u00A0",'')
		key["tweet"].tr!("\n",'')
		key.delete('parent')
		db.execute(insert_query, [key["img"], key["fullname"], key["username"], key["time"], key["tweet"], key["favorite"], key["retweet"]])
	end
	catch :wannaquit do

		while true
			puts driver.find_elements(:css, '.content').last.location_once_scrolled_into_view

			# Wait for the additional images to load
			puts current_count = driver.find_elements(:css, '.content').length
			count = 0
			until current_count < driver.find_elements(:css, '.content').length
			  count = count+1
			  throw :wannaquit if(count>100)
			  sleep(1)
			end

			puts driver.find_elements(:css, '.content').length

			driver.execute_script("getTweets()")
			a = driver.execute_script("return parsedTweets")
			checked = false
			a.each do |key|
				temp = key["parent"].scan(/ProfileTweet-actionCountForA.*/)
				key["favorite"]=temp[1].split('>')[1].split(' ')[0]
				key["retweet"]=temp[0].split('>')[1].split(' ')[0]
				key["tweet"].tr!("\u00A0",'')
				key["tweet"].tr!("\n",'')
				key.delete('parent')
				db.execute(insert_query, [key["img"], key["fullname"], key["username"], key["time"], key["tweet"], key["favorite"], key["retweet"]])
				#puts DateTime.strptime(key["time"],'%s')
				#puts DateTime.strptime(key["time"],'%s').to_date < startdate
				a = DateTime.parse(startdate.to_s)
				b = DateTime.strptime(key["time"],'%s')
				checked=true if(((b - a) * 24 * 60 * 60).to_i < 3600)
			end
			throw :wannaquit if(checked)
		end
	
	end
	# Check how many elements are there now

	#posts_text = driver.find_element(:css, css_selector).text
	#puts posts_text
	
	puts "coming"
	driver.quit
end