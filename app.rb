get "/" do
  #this is an example of using memcached; set to expire in 60 seconds
  @content = settings.cache.fetch('hello-world-message', 60) do
    "Hello World from Memcachier"
  end

  ap session[:userinfo]

  @files = admin_client.root_folder_items.files

  haml :index
end

get "/doc/:doc_id" do
  @file = admin_client.file(params['doc_id'])

  haml :doc
end



#Auth0 actions
get "/auth0/callback" do
  session[:userinfo] = request.env["omniauth.auth"]
  ap session[:userinfo]
  redirect to('/')
end

get "/auth0/failure" do
  puts "error in Auth0"
end



private

running_dir = File.dirname(__FILE__)
running_dir = Dir.pwd if (running_dir == '.')
PRIVATE_KEY = OpenSSL::PKey::RSA.new File.read("#{running_dir}/#{ENV['JWT_SECRET_KEY_PATH']}"), ENV['JWT_SECRET_KEY_PASSWORD']
TOKEN_TTL = 2700 #45 minutes

def admin_client
  access_token = settings.cache.fetch("box_tokens/enterprise", TOKEN_TTL) do
    puts "getting new enterprise token"
    response = Boxr::get_enterprise_token(PRIVATE_KEY)
    response.access_token
  end
  Boxr::Client.new(access_token)
end