require 'rubygems'
require 'sinatra'
require 'mongo'
require 'json'
require 'haml'

configure do
  conn = Mongo::Connection.new("localhost", 27017)
  set :mongo_connection, conn
  set :mongo_db,         conn.db('hw2')
end

helpers do
  # a helper method to turn a string ID
  # representation into a BSON::ObjectId
  def object_id val
    BSON::ObjectId.from_string(val)
  end

  def document_by_id id
    id = object_id(id) if String === id
    settings.mongo_db['ip'].
      find_one(:_id => id).to_json
  end
end

get '/' do
  t1 = Time.new
  @date = t1.strftime("%m-%d-%y")
  @ip = request.ip
  settings.mongo_db['ip'].insert( {"date" => @date, "ip" => @ip} )
  @datelist = settings.mongo_db['ip'].distinct('date')
  
  haml :hello
end

__END__
@@ hello
%p Hello World
%p
  -@datelist.each do |d|
    %p #{d} = #{settings.mongo_db['ip'].find({date:"#{d}"}).count()}