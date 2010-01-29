require 'redis'

class RedisAdapter
  def initialize(db=0)
    @r = Redis.new :db => db
  end
  
  def redis
    @r
  end
  
  def list_for(email)
    "craigslist:#{email}"
  end
  
  def all_subscriptions
    subscriptions = {}
    emails = @r.list_range("craigslist:allemails", 0, -1)
    emails.each do |email|
      searchterms = @r.list_range(list_for(email), 0, -1)
      terms = {}
      searchterms.each_with_index do |searchterm, index|
        terms.merge!({index => searchterm})
      end
      subscriptions.merge!({email => terms})
    end
    subscriptions
  end
  
  def store_email(email)
    @r.push_tail("craigslist:allemails", email) if @r.list_range("craigslist:allemails").index {|i| i == email}
  end
  
  def create_subscription(email, term)
    store_email(email)
    @r.push_head(list_for(email), term)
  end

  def read_subscriptions(email)
    posts = @r.list_range(list_for(email), 0, -1)
    return nil if posts[0].nil?
    posts
  end
  
  def update_subscription(email, oldterm, newterm)
    @r.llen(list_for(email)).times do |i|
      @r.lset(list_for(email), i, newterm) if @r.lindex(list_for(email), i) == oldterm
    end
  end
  
  def destroy_subscription(email, term)
    @r.llen(list_for(email)).times do |i|
      @r.lrem(list_for(email), i, term) if @r.lindex(list_for(email), i) == term
    end 
  end
  
  def newest_listing
    @r["craigslist:newest_listing"]
  end
  
  def newest_listing=(listing)
    @r["craigslist:newest_listing"] = listing
  end
  
  def queue_job(id, data)
    @r.sadd("craigslist:jobs", id)
    @r["craigslist:#{id}"] = data
  end
  
  def get_job
    @r.srandmember("craigslist:jobs")
  end
  
  def jobs_available?
    @r.scard("craigslist:jobs") > 0
  end
  
  def data_for(id)
    @r["craigslist:#{id}"]
  end
  
  def finish(id)
    @r.srem("craigslist:jobs", id)
    @r.expire("craigslist:#{id}", 1)
  end
end