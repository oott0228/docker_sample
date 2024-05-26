class User < ApplicationRecord
  # composed_ofを使う場合この1行でいい
  # composed_of :phone_number, mapping: %w[phone_number value]
  
  def phone_number
    # @phone_numberインスタンスヘンスが存在しない場合、self[:phone_number]の値を使ってPhoneNumberオブジェクトを作成する
    @phone_number ||= PhoneNumber.new(self[:phone_number])
  end

  # Userオブジェクトのphone_number属性に新しい値を設定するためのメソッド
  def phone_number=(new_phone_number)
    # new_phone_numberオブジェクトのvalue属性の値を、Userオブジェクトのphone_number属性に代入する
    self[:phone_number] = new_phone_number.value
    # new_phone_numberオブジェクトを@phone_numberに代入することで、次回phone_numberメソッドが呼び出されたときに新PhoneNumberオブジェクトが返される
    @phone_number = new_phone_number
  end
end
