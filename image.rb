require 'sinatra'
require 'gollum-lib'
require 'tempfile'
require 'zip/zip'

def index ( message=nil )
	response = File.read(File.join('.', 'index.html'))
	response.gsub!( "<!-- message -->\n", "<h2>Received and unpacked #{message}</h2>") if message
	response
end

wiki = Gollum::Wiki.new(".")

get '/' do
	index()
end

post '/unpack' do
	@repo = Rugged::Repository.new('.')
	@index = Rugged::Index.new

	zip = params[:zip][:tempfile]
	Zip::ZipFile.open( zip ) { |zipfile| 
		zipfile.each do |f|
			contents = zipfile.read( f.name )
			filename = f.name.split( File::Separator ).pop
			if contents and filename and filename =~ /(png|jp?g|gif)$/i
				puts "Writing out: #{filename}"
			end
		end
	}
	index( params[:zip][:filename] )
end