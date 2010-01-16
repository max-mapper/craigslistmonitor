before do
  @db = RedisAdapter.new
end

get '/' do
  haml :index
end

post '/subscribe' do
  content_type :json
  if params[:email] && params[:term]
    @db.create_subscription(params[:email], params[:term]) 
    status = {:message => "Subscription successful", :success => "success"}
  else
    status = {:message => "Error subscribing. Please try again"}
  end
  status.to_json
end

get '/manage' do
  content_type :json
  if params[:email]
    subscriptions = {}
    subscriptions_from_database = @db.read_subscriptions(params[:email])
    unless subscriptions_from_database.nil?
      subscriptions_from_database.each_with_index do |subscription, index|
        subscriptions.merge!({index => {"subscription" => subscription}})
      end
    end
  end
  subscriptions = {"0" => {"subscription" => "none", "message" => "No subscriptions for that email"}} if subscriptions.empty?
  subscriptions.to_json
end
