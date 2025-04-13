require 'sinatra/base'
require 'sequel'
require 'json'
require 'sinatra/namespace'

require_relative 'app/user'
require_relative 'app/loyalty_levels'
require_relative 'app/product'
require_relative 'app/calculate_order'
require_relative 'app/operation_confirmer'



DB = Sequel.connect("sqlite://database/test.db")


class Application < Sinatra::Base
  
  register Sinatra::Namespace

  def errors
    yield
  rescue JSON::ParserError
    { status: 'error', message: 'Неверный формат JSON' }.to_json
  rescue => e
    { status: 'error', message: e.message }.to_json
  end

  namespace '/api' do
    before do
      content_type :json
      @confirmation = OperationConfirmer.new(DB)
    end

    post '/operation' do
      errors do
        input_data = JSON.parse(request.body.read)
        @confirmation.request_for_confirmation(input_data).to_json
      end
    end

    post '/submit' do
      errors do
        input_data = JSON.parse(request.body.read)
        @confirmation.confirm_operation(input_data).to_json
      end
    end
  end
end
