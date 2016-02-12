require 'sinatra'
require 'sinatra/contrib'
require 'json'

get '/' do
  return %q(Welcome to Web 101, let's try getting another path. How about GET /this/is/a/path)
end

get '/this/is/a/path' do
  return %q(Good job!)
end

post '/beam_me_up' do
  return %q(Very nice. This was a post)
end

get '/format' do
  respond_with :index, :name => 'example' do |f|
    f.txt { 'This is plain text.' }
    f.html { 'Here is some <strong>html</strong>' }
    f.json do
      {
        declaration: 'json is the best',
        xml: 'is unreadable'
      }.to_json
    end
    f.xml do
      content_type 'text/xml'
      "<foo>bar</foo><xml>sucks</xml>"
    end
  end
end
