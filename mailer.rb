require 'rubygems'
require 'pony'
require 'db'

@db = RedisAdapter.new

# assumes sendmail or some other MTA is installed
def mail(href, to, subscription)
  Pony.mail(
    :from => 'craigslistbot@maxogden.com', 
    :subject=> "Craigslist alert for #{subscription}!",
    :body => "Found #{subscription} on the page http://portland.craigslist.org#{href}.html !",
    :to => to,
    :via => :smtp, :smtp => {
      :host   => 'localhost',
      :domain => "localhost.localdomain"
    }
  )
end

while @db.jobs_available? do
  job = @db.get_job
  values = Marshal.load(@db.data_for(job))
  mail(values[0], values[1], values[2])
  @db.finish(job)
end

