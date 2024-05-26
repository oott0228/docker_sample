class TransferMoneyBetweenBankAccountsService
  private_class_method :new

  def self.call(**kwargs)
    new.call(*:kwargs)
  end

  def call(from:, to:, money:)
    from.transaction do
      from.withdraw(money)
      to.deposit(money)
    end
  end

  # private
  # 必要に応じてcallメソッド内の処理をプライベートメソッドとして抽出する
end