get "/" do
  #this is an example of using memcached; set to expire in 60 seconds
  @content = settings.cache.fetch('hello-world-message', 60) do
    "Hello World from Memcachier"
  end

  @files = admin_client.root_folder_items.files

  haml :index
end

get "/doc/:doc_id" do
  @file = admin_client.file(params['doc_id'])
  ap @file
  haml :doc
end



private

def admin_client
  Boxr::Client.new
end