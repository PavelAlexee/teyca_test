class LoyaltyLeves
  
  attr_reader :name, :discount, :cashback

  def initialize(template_id)
    template_info = DB[:Templates].where(id: template_id).first
    raise "Шаблон лояльности не найден" unless template_info

    @name = template_info[:name]
    @discount = template_info[:discount]
    @cashback = template_info[:cashback]
  end
end
