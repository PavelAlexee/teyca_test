require 'sinatra'
require 'sequel'
require 'json'

require_relative 'app/user'
require_relative 'app/loyalty_levels'
require_relative 'app/product'
require_relative 'app/calculate_order'
require_relative 'app/operation_confirmer'


DB = Sequel.connect("sqlite://database/test.db")

before do
  content_type :json
  request.body.rewind
end


@users = DB[:Users]
@templates = DB[:Templates] 
@products = DB[:Products]
@operations = DB[:Operations]


post '/operation' do
  begin
    input_data = JSON.parse(request.body.read)  
    confirmation = OperationConfirmer.new
    confirmation.request_for_confirmation(input_data).to_json

  rescue JSON::ParserError
    { status: 'error', message: 'Неверный формат JSON' }.to_json
  rescue => e
    { status: 'error', message: e.message }.to_json
  end
end



post '/sumbit' do
  
  begin
    input_data = JSON.parse(request.body.read)
    
    confirmer = OperationConfirmer.new
    response = confirmer.confirm_operation(input_data)
    response.to_json
  rescue JSON::ParserError
    { status: 'error', message: 'Неверный формат JSON' }.to_json
  rescue => e
    { status: 'error', message: e.message }.to_json
  end

end
