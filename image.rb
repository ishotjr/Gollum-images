require 'sinatra'
require 'gollum-lib'

wiki = Gollum::Wiki.new(".")
set :views, "."

get '/pages' do
	"All pages: \n" + wiki.pages.collect { |p| p.path }.join{ "\n" }
end