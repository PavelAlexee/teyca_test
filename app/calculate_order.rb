class CalculateOrder

  attr_reader :summ_product, :cashback_product, :discount_product, :noloyalty_product, :items

  def initialize(request)
    @request = request
    @items = []
    
    @summ_product = 0
    @cashback_product = 0
    @discount_product = 0 
    @noloyalty_product = 0
  end

  def calculate(db_product)
    summ = 0

    @request['positions'].each do |i|

      product = Product.new(i["id"])


      case product.type
      when 'increased_cashback'
        cashback= (i["price"] * product.value.to_i) / 100
        cashback *= i['quantity']

        @cashback_product += cashback
    
        summ += i['quantity'] * i["price"]
      when 'discount'
        discount = i["price"] * ((product.value.to_i) / 100)
        discount *= i['quantity']
        
        @discount_product += discount

        summ += i['quantity'] * i["price"]
      when 'noloyalty'
        noloyalty = i['quantity'] * i["price"]
        @noloyalty_product += noloyalty
      else
        summ += i['quantity'] * i["price"]
      end
 
      @items << {
        type: product.type,
        value: product.value,
        description: product.name,
        discount_percent: discount,
        discount_value: ""
      }
    end
  
    @summ_product = summ + @noloyalty_product
  end
end
