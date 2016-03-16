require 'sinatra'
require 'sinatra/contrib'
require 'json'
# require 'pry'

get '/' do
  @hostname = human_host_name
  erb :index
end

get '/this/is/a/path' do
  @hostname = human_host_name
  @url = human_url
  @protocol = request.scheme + '://'
  erb :path
end

post '/beam_me_up' do
  return %q(Very nice. This was a post)
end

get '/params' do
  @params = params
  scheme = request.scheme || 'http'
  @url = scheme + '://' + human_host_name + '/params'
  @show_next = params.include? 'name'
  erb :params
end

get '/formats' do
  respond_with :index, :name => 'example' do |f|
    f.txt { 'This is plain text.' }
    f.html do
      erb :formats
    end
    f.on('application/json') do
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

get '/headers' do
  keys = request.env.keys.select { |h| h.start_with? 'HTTP_'}
  @headers = {}
  keys.each do |key|
    value = request.env[key]
    @headers[key.gsub('HTTP_', '')] = value
  end
  erb :headers
end

get '/FIXME' do
  return %q(Oops! Looks like some part of the app is not complete)
end

private

def human_host_name
  hostname = request.host
  hostname += ":#{request.port}" if request.port != 80 && request.port != 443
  hostname
end

def human_url
  request.url
end

# -----------------------------------------------------------------------------
# DND stuff
# -----------------------------------------------------------------------------

enable :sessions

before /dnd\/*/ do
  if request.url.match(/.json$/)
    request.accept.unshift('application/json')
    request.path_info.gsub!(/.json$/, '')
  end
end

PARTY = [{id: 1, name: 'Francis', class: 'Warlock',    level: 8},
         {id: 2, name: 'Greg',    class: 'Warrior',    level: 10},
         {id: 3, name: 'Scott',   class: 'Fighter',    level: 9},
         {id: 4, name: 'Jay',     class: 'Bard',       level: 10},
         {id: 5, name: 'Tabrez',  class: 'Rogue',      level: 10}].freeze

get '/dnd/party' do # index
  party = PARTY
  if session[:dnd_id]
    new_member = { id: session[:dnd_id],
                   name: session[:name],
                   class: session[:class],
                   level: session[:level] }
    party += [new_member]
  end

  respond_with :index, name: 'example' do |f|
    f.html do
      erb :'dnd/party', locals: { party: party }
    end
    f.on('application/json') do
      response_hash = { party: party,
                        join_link: '/dnd/join.json' }
      response_hash.to_json
    end
  end
end

get '/dnd/join' do # new
  render_join_form
end

post '/dnd/join' do # create
  name = params['name']
  klass = params['class']
  level = params['level'].to_i

  render_join_form('Uh-oh! Params mismatch') and return unless name && klass
  halt 500 unless level
  render_join_form('Sorry, but you\'re outside our level range!') and return if level < 8 || level > 10

  status 201

  dnd_id = PARTY.size + 1

  session[:dnd_id] = dnd_id
  session[:name] = name
  session[:class] = klass
  session[:level] = level

  new_party = PARTY + [{ id: dnd_id, name: name, class: klass, level: level }]

  respond_with :index, name: 'I still don\'t get this' do |f|
    f.html do
      erb :'dnd/party', locals: { party: new_party }
    end
    f.on('application/json') do
      new_party.to_json
    end
  end
end

def render_join_form(error = nil)
  new_member = { name: 'Bob', class: 'Barbarian', level: 9 }
  respond_with :index, name: 'why does this exist' do |f|
    f.html do
      erb :'dnd/join', locals: {new_member: new_member, error: error}
    end
    f.on('application/json') do
      json_hash = {format: new_member}
      if error
        json_hash[:error] = error
        status 409
      end
      json_hash.to_json
    end
  end
end

get '/v2/dnd/join' do
  new_member = { name: 'Bob', class: 'Barbarian', level: 9 }
  erb :'dnd/join2', locals: { new_member: new_member }
end

post '/v2/dnd/join' do
  name = params['name']
  klass = params['class']
  level = params['level']

  halt 400 unless name && klass && level
  halt 400 if name.empty? || klass.empty? || level.empty?

  level = level.to_i
  halt 409, 'Your level is outside our range!' if level < 8 || level > 10

  session[:dnd_id] = PARTY.size + 1
  session[:name] = name
  session[:class] = klass
  session[:level] = level

  halt 201
end

# -----------------------------------------------------------------------------
# DND Example end
# -----------------------------------------------------------------------------

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

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
