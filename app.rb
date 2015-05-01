get "/" do
  @content = "Hello World!"

  box = Boxr::Client.new
  @files = box.root_folder_items.files

  haml :index
end