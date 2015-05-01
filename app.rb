get "/" do
  @content = settings.cache.fetch('my-key-2', 60) do
    puts 'cache miss'
    "hello world!"
  end

  box = Boxr::Client.new
  @files = box.root_folder_items.files

  haml :index
end