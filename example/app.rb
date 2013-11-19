require 'bundler'
Bundler.setup
require 'sinatra/base'
require 'tilt'
require 'active_support/json'

Tilt.register :html, Tilt[:erb]

class ExampleApp < Sinatra::Base
  helpers do
    def html(*args) render(:html, *args) end
  end

  get '/' do
    html :index
  end

  get '/runner' do
    html :runner
  end
end
