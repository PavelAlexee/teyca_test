class Product
  attr_reader :id, :name, :type, :value

  def initialize(product_id)
    product_info = DB[:Products].where(id: product_id).first

    if product_info
      @id = product_info[:id]
      @name = product_info[:name]
      @type = product_info[:type]
      @value = product_info[:value]
    else
      @id = product_id
      @name = "Неизвестный товар"
      @type = nil
      @value = nil
    end
  end
end
