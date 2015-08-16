require 'sinatra'
require 'gollum-lib'
require 'tempfile'
require 'zip'
require 'rugged'

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
	Zip::File.open( zip ) { |zipfile| 
		zipfile.each do |f|
			if f.file?
				contents = f.get_input_stream.read
				filename = f.name.split( File::Separator ).pop
				if contents and filename and filename =~ /(png|jp?g|gif)$/i
					puts "Writing out: #{filename}"
					f.extract(filename)					
				end
			end
		end
	}
	index( params[:zip][:filename] )
end