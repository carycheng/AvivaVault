get "/" do
  @content = "Hey there"
  haml :index
end