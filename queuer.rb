require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'gearman'
require 'db'
Thread.new { EM.run } unless EM.reactor_running?
@db = RedisAdapter.new

client = Gearman::Client.new('localhost')
taskset = Gearman::Taskset.new

doc = Nokogiri::HTML(open('http://portland.craigslist.org/mlt/sss/'))
posts = {}
doc.css('.p').each_with_index do |link, index|
  href = link.parent.css('a').first['href'].split('.')[0]
  posts.merge!({index => href})
end
listings = {}
posts.sort.each do |post|
  listing = Nokogiri::HTML(open("http://portland.craigslist.org#{post[1]}.html"))
  listings.merge!(post[1] => listing.css("#userbody"))
end
listings.each do |href, listing|
  @db.all_subscriptions.each do |subscriptions|
    email = subscriptions[0]
    subscriptions[1].each do |index, subscription|
      if listing.to_s =~ /#{Regexp.quote(subscription)}/
        p "match!"
        task = Gearman::Task.new("email", Marshal.dump([href, email, subscription]))
        task.on_complete {|r| puts "Sent #{subscription} notification email to #{email}!" }
        task.on_exception {|ex| puts "This should never be called" }
        task.on_warning {|warning| puts "WARNING: #{warning}" }
        task.on_retry { puts "PRE-RETRY HOOK: retry no. #{task.retries_done}" }
        task.on_fail { puts "TASK FAILED, GIVING UP" }
        taskset << task
      end
    end
  end
end

client.run(taskset)