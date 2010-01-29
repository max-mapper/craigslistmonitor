require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'db'

class CraigslistFetcher
  def initialize()
    @db = RedisAdapter.new
  end

  def current_listings
    doc = Nokogiri::HTML(open('http://portland.craigslist.org/mlt/sss/'))
    posts = []
    doc.css('.p').each_with_index do |link, index|
      href = link.parent.css('a').first['href'].split('.')[0]
      posts << href
    end
    posts
  end

  def filter_new(posts)
    @first_old_post = posts.index{|post| @db.newest_listing == post}
    posts = posts[0...@first_old_post] if @first_old_post
    unless posts == []
      @db.newest_listing = posts.first
    end
    posts
  end

  def content_of(posts)
    listings = []
    posts.each do |post|
      listing = Nokogiri::HTML(open("http://portland.craigslist.org#{post}.html")) rescue nil      
      listings << [post, listing.css("#userbody")] if listing
    end
    listings
  end

  def queue(listings)
    listings.each do |href, listing|
      @db.all_subscriptions.each do |subscriptions|
        email = subscriptions[0]
        subscriptions[1].each do |index, subscription|
          if listing.to_s =~ /#{Regexp.quote(subscription)}/i
            @db.queue_job(href, Marshal.dump([href, email, subscription]))
          end
        end
      end
    end
  end
end

@fetcher = CraigslistFetcher.new()
posts = @fetcher.current_listings
unprocessed_posts = @fetcher.filter_new(posts)
@fetcher.queue(@fetcher.content_of(unprocessed_posts)) unless unprocessed_posts == []