require 'sinatra'
require 'slim'

set :public_folder, File.dirname(__FILE__) + '/assets'
set :port, 8000

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
  if (params[:format] =~ /^\d{4}\-\d{2|\-\d{2}$/)
    file = params[:format] + ".csv"
  else
    file = 'latest.csv'
  end

  filepath = "assets/data/#{file}"
  if File.exists?(filepath)
    content_type 'application/csv'
    return File.open(filepath)
  else
    redirect '/latest'
  end
end
