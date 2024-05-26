class BankAccount < ApplicationRecord
  # Moneyクラスとbalance属性を関連づける。
  # BankAccountクラスのbalance属性とcurrency属性を、Moneyクラスのamount属性とcurrency属性にマッピングする
  composed_of :balance, class_name: "Money", mapping: [%w[balance amount], %w[currency currency]]

  def deposit(money)
    # with_lockブロックで、DBのレコードをブロックしながら更新処理を行う
    with_lock { update!(balance: balance + money) }
  end

  def withdraw(money)
    with_lock do
      raise "Withdrawal amount must be greater than balance" if money > balance
      update!(balance: balance - money)
    end
  end
end
