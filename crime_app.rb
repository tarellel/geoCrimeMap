require 'sinatra'
require 'bundler'
require 'slim'
require 'sinatra/assetpack'

class CrimeApp < Sinatra::Base
  set :public_folder, File.dirname(__FILE__) + '/assets'
  set :port, 8000
  set :root, File.dirname(__FILE__)
  set :rack_env, :production

  register Sinatra::AssetPack
  assets {
    serve '/js',     from: 'assets/js'
    serve '/css',    from: 'assets/css'
    serve '/img',    from: 'assets/img'

    # Serve up JS per request
    js :app, '/js/app.js', [
      '/js/app.js',
      '/js/count.js'
    ]

    # Serve up CSS per request
    css :application, '/css/application.css', [
      '/css/style.css',
      '/css/map.css'
    ]

    # jsmin, yui, closure or uglify for js compression
    js_compression  :uglify
    # simple, sass, yui, or sqwish for css compression
    css_compression :sass
  }

  # Slim will output HTML that is clean and legible, rather than compressed
  configure do
    set :slim, pretty: true
  end

  # sass: http://ricostacruz.com/sinatra-assetpack/
  get '/' do
    slim :index
  end

  # serve the latest generated csv file
  get '/latest' do
    content_type 'application/csv'
    File.read('assets/data/latest.csv')
  end

  get '/csv/:format.csv' do
    # verify format of file is similar to YYYY-DD-MM
    if params[:format] =~ /^\d{4}\-\d{2|\-\d{2}$/
      file = params[:format] + '.csv'
    else
      file = 'latest.csv'
    end

    filepath = "assets/data/#{file}"
    if File.exist?(filepath)
      content_type 'application/csv'
      return File.open(filepath)
    else
      redirect '/latest'
    end
  end
end
