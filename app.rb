get "/" do
  #this is an example of using memcached; set to expire in 60 seconds
  @message = settings.cache.fetch('memcachier-message', 60) do
    "Memcachier connection is live"
  end

  @files = admin_client.root_folder_items.files
  haml :index
end

get "/dashboard" do
  requires_login

  @items = user_client.root_folder_items
  haml :dashboard
end

get '/important' do
  haml :portal
end 

get '/personal' do
  @items = user_client.root_folder_items
  haml :vault
end 
 
get "/doc/:id" do
  requires_login

  @file = user_client.file(params[:id])
  haml :doc_details
end

get "/download/:id" do
  url = user_client.download_url(params[:id])
  redirect to url
end

get "/thumbnail/:id" do
  image = user_client.thumbnail(params[:id], min_height: 256, min_width: 256)
  response.write(image)
end

get "/logout" do
  begin
    auth0_client.delete_user(session[:userinfo]['uid'])
    admin_client.delete_user(session[:box_id], notify: false, force: true)
  rescue => ex
    puts ex.message
  end

  session.clear
  redirect to '/'
end

get "/auth0/callback" do
  session[:userinfo] = request.env["omniauth.auth"]
  
  auth0_meta = session[:userinfo]['extra']['raw_info']['app_metadata']
  if auth0_meta and auth0_meta.has_key?('box_id')
    puts "found box_id in auth0 metadata"
    session[:box_id] = auth0_meta['box_id']   
  else
    #create box app user
    uid = session[:userinfo]['uid']
    box_name = session[:userinfo]['info']['name']
    box_user = admin_client.create_user(box_name, is_platform_access_only: true)
    session[:box_id] = box_user.id

    #store the box_id in Auth0
    auth0_client.patch_user_metadata(uid, { box_id: box_user.id})

    setup_box_account

    puts "created new box user and set box_id in auth0 metadata"
  end

  redirect to '/dashboard'
end

get "/auth0/failure" do
  puts "error in Auth0"
end

#this will delete all the logins in Auth0 and all the Box app users
get "/reset-logins" do
  begin
    logins = auth0_client.users
    logins.each do |login|
      box_user_id = login["box_id"]
      if box_user_id
        admin_client.delete_user(box_user_id, notify: false, force: true)
      end

      auth0_client.delete_user(login["user_id"])
    end

    @message = "Successfully deleted #{logins.count} logins."
  rescue => ex
    @message = ex.message
  end

  session.clear
  haml :reset_logins
end

private

running_dir = File.dirname(__FILE__)
running_dir = Dir.pwd if (running_dir == '.')
PRIVATE_KEY = OpenSSL::PKey::RSA.new ENV['JWT_SECRET_KEY'], ENV['JWT_SECRET_KEY_PASSWORD']
TOKEN_TTL = 2700 #45 minutes

def setup_box_account
  #this is where you would set up the new app user's initial files, folders, permissions, etc.
  user_client.create_folder("Test Folder", Boxr::ROOT)
  user_client.upload_file("test.txt", Boxr::ROOT)
end

def requires_login
  redirect to('/') unless session[:userinfo]
end

def admin_client
  access_token = settings.cache.fetch("box_tokens/enterprise", TOKEN_TTL) do
    puts "getting new enterprise token"
    response = Boxr::get_enterprise_token(PRIVATE_KEY)
    response.access_token
  end
  Boxr::Client.new(access_token)
end

def user_client(user_id=session[:box_id])
  access_token = settings.cache.fetch("box_tokens/user/#{user_id}", TOKEN_TTL) do
    puts "getting new user token"
    response = Boxr::get_user_token(PRIVATE_KEY, user_id)
    response.access_token
  end
  
  Boxr::Client.new(access_token)
end

def auth0_client
  Auth0Client.new(
    :client_id => ENV['AUTH0_CLIENT_ID'],
    :client_secret => ENV['AUTH0_CLIENT_SECRET'],
    :namespace => ENV['AUTH0_DOMAIN']
  )
end