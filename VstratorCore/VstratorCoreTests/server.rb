# RestKit Sinatra Testing Server
# Place at Tests/server.rb and run with `ruby Tests/Server.rb` before executing the test suite within Xcode

require 'rubygems'
require 'sinatra'
require 'json'

configure do
  set :logging, true
  set :dump_errors, true
  set :public_folder, Proc.new { File.expand_path(File.join(root, 'Fixtures')) }
end

def render_fixture(filename)
  send_file File.join(settings.public_folder, filename)
end

helpers do
    def request_headers
        env.inject({}){|acc, (k,v)| acc[k.downcase.to_sym] = v if k; acc} # if k =~ /^http_(.*)/i; acc}
    end
end

module Sinatra
    class Base
        private
        def self.request_method(*meth)
            condition do
                this_method = request.request_method.downcase.to_sym
                if meth.respond_to?(:include?) then
                    meth.include?(this_method)
                else
                    meth == this_method
                end
            end
        end
    end
end


def request_body(key)
    @request_payload && @request_payload[key]
end

before :request_method => [:post, :put] do
    if request_headers[:content_type] =~ /application\/json/
        request.body.rewind
        @request_payload = JSON.parse request.body.read
    end
end

#################################################

get '/sports' do
    render_fixture('Sports.json');
end

get '/user' do
    render_fixture('UserInfo.json');
end

post '/user/register' do
    if request_body('email') == 'foo@bar.com' && request_body('password') == 'secret'
        status 200
    else
        status 422
    end
end

put '/user' do
    if request_body('email') == 'foo@bar.com' && request_body('firstName') == 'Foo' && request_body('lastName') == 'Bar'
        status 200
    else
        status 422
    end
end

post '/user/password' do
    if request_body('oldPassword') == '123456' && request_body('newPassword') == 'secret'
        status 200
    else
        status 422
    end
end

post '/feedback' do
    if request_body('issueType') == 1 && request_body('description') == "1\ntest"
        status 200
    else
        status 422
    end
end

############# Upload ############################

get '/clip' do
    render_fixture('UploadRequestInfo.json')
end

post '/clip' do
    if request_body('recordingKey') == '123123123' &&
       request_body('title') == "Rafa's ace"
       request_body('action') == 'Serve' &&
       request_body('sport') == 'Tennis'
        render_fixture('VideoStatusInfo.json')
    else
        status 422
    end
end

get '/clip/:videoKey' do
    render_fixture('VideoStatusInfo.json')
end

put '/clip' do
    if request_body('title') == "Rafa's ace"
       request_body('action') == 'Serve' &&
       request_body('sport') == 'Tennis'
        status 200
    else
        status 422
    end
end

############# Notifications ######################

get '/notification' do
    render_fixture('NotificationInfo.json')
end

put '/notification/:id' do
    status 200
end

############# Download #########################

get '/contentdownloads' do
    render_fixture('MediaTypes.json')
end

get '/contentdownloads/:id' do
    render_fixture('Medias.json')
end

get '/contentsets' do
    render_fixture('ContentSets.json')
end

post '/contentsets/:id' do
    render_fixture('ContentSetInfo.json')
end

############## Errors ###########################

get '/not_found' do
    status 404
    content_type 'application/json'
    '{"message":"Not found"}'
end

get '/forbidden' do
    status 403
    content_type 'application/json'
    '{"message":"Forbidden"}'
end

get '/unauthorized' do
    status 401
    content_type 'application/json'
    '{"message":"Unauthorized"}'
end

# Return a 503 response to test error conditions
get '/offline' do
    status 503
end

# Simulate a JSON error
get '/error' do
  status 400
  content_type 'application/json'
  "{f36a311cba6c29ba4c54f0b8c76e6cb733c01e65quot;errorf36a311cba6c29ba4c54f0b8c76e6cb733c01e65quot;: f36a311cba6c29ba4c54f0b8c76e6cb733c01e65quot;An error occurred!!f36a311cba6c29ba4c54f0b8c76e6cb733c01e65quot;}"
end

get '/errors_in_form' do
    status 422
    content_type 'application/json'
    '{"errors":{"foo":["bar"],"baz":["qux","zoo"]}}'
end
