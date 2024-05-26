class BankAccountMoneyTransfer < ApplicationRecord
  composed_of :money, mapping: [%w[amount amount], %w[currency currency]]

  belongs_to :from, class_name: "BankAccount"
  belongs_to :to, class_name: "BankAccount"

  validate :attributes_can_be_represented_as_money

  before_create :transfer_money

  private

  def attributes_can_be_represented_as_money
    # Moneyオブジェクトを初期化できるかどうかを確かめる
    money
    
  rescue
    # 何らかのエラーが発生した場合、対応するモデルの属性（amount、currency）の値が不正であるとみなす
    # ActiveRecord::Base.reflect_on_aggreationメソッドを使って属性名を動的に取得している
    self.class.reflect_on_aggreation(:money).mapping.each do |attribute, _|
      errors.add(attribute, :invalid)
    end
  end

  def transfer_money
    from.withdraw(monay)
    to.deposit(money)
  end
end
