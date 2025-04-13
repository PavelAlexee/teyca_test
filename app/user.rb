class User

  attr_reader :id, :template_id, :name, :bonus

  def initialize(user_id, db)
    @user_id = user_id

    user_info = db[:Users].where(id: @user_id).first
    raise "Пользователь не найден" unless user_info

    @id = user_info[:id]
    @template_id = user_info[:template_id]
    @name = user_info[:name]
    @bonus = (user_info[:bonus].to_f * 1).to_i 
  end
end
