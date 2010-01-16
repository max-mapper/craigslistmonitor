require 'rubygems'
require 'pony'
require 'gearman'

def mail(href, to, subscription)
  Pony.mail(:from => 'craigslistbot@maxogden.com', 
            :subject=> "Craigslist alert!",
            :body => "Found #{subscription} on the page http://portland.craigslist.org#{href}.html !!",
            :to => to,
            :via => :smtp, :smtp => {
              :host   => 'smtp.gmail.com',
              :port   => '587',
              :tls    => true,
              :user   => 'craigslistbot@maxogden.com',
              :password   => 'craigslist',
              :auth   => :plain, # :plain, :login, :cram_md5, no auth by default
              :domain => "localhost.localdomain" # the HELO domain provided by the client to the server
            }
           )
end

worker = Gearman::Worker.new('localhost')

worker.add_ability('email') do |data, job|
  values = Marshal.load(data)
  p values
  mail(values[0], values[1], values[2])
end

worker.work