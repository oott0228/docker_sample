class Money < ApplicationRecord
  # Comparableモジュールをincludeすることで、<=>演算子を定義して、Moneyオブジェクトどうしを比較できるようになる
  include Comparable

  attr_reader :amount, :currency
  alias eql? ==

  def initialize(amount, currency = :JPY)
    # BigDecimalオブジェクトに変換することで金額の計算を正確に行う
    @amount = BigDecimal(amount)
    raise "Amount must not be negative" if @amount.negative?

    #  通過をSymbolオブジェクトに変換する
    @currency = currency.to_sym
  end

  def <=>(other)
    return nil if self.class != other.class || currency != other.currency
    amount <=> other.amount
  end

  def +(other)
    raise "Currency is different" unless currency == other.currency
    self.class.new(amount + other.amount, currency)
  end

  def -(other)
    raise "Currency is different" unless currency == other.currency
    self.class.new(amount - other.amount, currency)
  end

  def hash
    [amount, currency].hash
  end
end
