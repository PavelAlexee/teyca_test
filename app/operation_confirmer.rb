class OperationConfirmer
  
  def initialize(db)
    @db = db
  end

  def request_for_confirmation(input_data)
    customer = User.new(input_data['user_id'], @db)
    customer_loyalty = LoyaltyLeves.new(customer.template_id)
  
    user_info = {
      name: customer.name, 
      loyalty: customer_loyalty.name, 
      bonus: customer.bonus.to_f
    }
  
    result = CalculateOrder.new(input_data)
    result.calculate(@db[:products])

    without_noloyalty = result.summ_product - result.noloyalty_product
    cashback_loyalty = (without_noloyalty) * (customer_loyalty.cashback / 100.0) 
    discount_user = (without_noloyalty) * (customer_loyalty.discount / 100.0)
    
    available = [without_noloyalty, user_info[:bonus]].min
        
                
    operation_id = insert_operation(
      result, 
      cashback_loyalty, 
      discount_user, 
      available,
      input_data['user_id']
    )  

    {
      status: "success",
      user_info: user_info,
      operation_id: operation_id,
      total_amount: (result.summ_product - discount_user - result.discount_product).round(2),
      bonus_info: {
        bonus_user: user_info[:bonus].round(2),
        available_to_write_off: available.round(2),
        total_cashback_percent: ((result.cashback_product + cashback_loyalty) / result.summ_product * 100).round(2),
        will_be_accrued: (result.cashback_product + cashback_loyalty).round(2)
      },
      discount_info: {
        total_discount_amount: (discount_user + result.discount_product).round(2),
        total_discount_percent: ((discount_user + result.discount_product) / result.summ_product * 100).round(2)
      },
      items: result.items
    }
  end 


  def confirm_operation(input_data)
    operation = @db[:operations].where(id: input_data['operation_id']).first
    raise "Операция не найдена" unless operation
    
    raise "Операция не принадлежит пользователю" if operation[:user_id] != input_data['user']['id']
    
    write_off = input_data['write_off'].to_f
    available = operation[:allowed_write_off].to_f
    
    raise "Недостаточно бонусов для списания" if write_off > available
    
    @db[:operations].where(id: input_data['operation_id']).update(
      write_off: write_off,
      done: true,
    )
    
    new_bonus = input_data['user']['bonus'].to_f - write_off + operation[:cashback].to_f
    @db[:users].where(id: input_data['user']['id']).update(bonus: new_bonus)
    
    {
      status: 'success',
      message: 'Операция успешно подтверждена',
      operation_info: {
        user_id: input_data['user']['id'],
        bonuses_cashback: operation[:cashback].round(2),
        cashback_percent: operation[:cashback_percent],
        total_discount: operation[:discount].round(2),
        discount_percent: operation[:discount_percent],
        write_off_bonuses: write_off.round(2),
        payment_amount: (operation[:check_summ] - write_off).round(2)
      }
    }
  end


  private


  def insert_operation(res, cashback_loyalty, discount_user, available, user_id)
    @db[:Operations].insert(
      user_id: user_id, 
      cashback: (res.cashback_product + cashback_loyalty).round(2), 
      cashback_percent: ((res.cashback_product + cashback_loyalty) / res.summ_product * 100).round(2), 
      discount: (discount_user + res.discount_product).round(2), 
      discount_percent: ((discount_user + res.discount_product) / res.summ_product * 100).round(2), 
      write_off: nil, 
      check_summ: (res.summ_product - discount_user - res.discount_product).round(2), 
      done: false, 
      allowed_write_off: available.round(2)
    )
  end

end
