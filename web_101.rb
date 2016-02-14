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

get '/formats' do
  respond_with :index, :name => 'example' do |f|
    f.txt { 'This is plain text.' }
    f.html do
      erb :formats
    end
    f.json do
      {
        declaration: 'json is the best',
        foo: 'bar',
        an_int: 1,
        null_value: nil,
        arrays_work_too: [:wiz, :bang, :baz],
        inception: { hash: 'inside a hash'},
        instructions: 'Visit GET /FIXME for the next section'
      }.to_json
    end
    f.xml do
      content_type 'text/xml'
      "<foo>bar</foo><xml>sucks</xml>"
    end
    f.on('application/soap+xml') do
      content_type 'text/xml'
      SOAP_STRING
    end
  end
end



private

SOAP_STRING = %q(<?xml version="1.0"?>
<soap:Envelope
xmlns:soap="http://www.w3.org/2003/05/soap-envelope/"
soap:encodingStyle="http://www.w3.org/2003/05/soap-encoding">

<soap:Header>
  <headers> Some heady information </headers>
</soap:Header>

<soap:Body>
  <message>Soap really sucks. Don't use it. </message>
</soap:Body>
</soap:Envelope>)
