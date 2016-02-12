require 'sinatra'
require 'json'

get '/' do
  return %q(Welcome to Web 101, let's try getting another path. How about GET /this/is/a/path)
end

get '/this/is/a/path' do
  return %q(Good job!)
end
