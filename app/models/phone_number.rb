class PhoneNumber < ApplicationRecord
  # 読み取り専用の属性を定義している
  attr_reader :value
  # hashメソッドをvalueに委譲する。phone_number.hashを呼ぶとvalueのhashメソッドが呼ばれる
  delegate :hash, to: :value

  def initialize(value)
    raise "Phone number is invalid" unless value.match?(/\A0\d{9,19}\z/)
    # valueが凍結されていたら複製して凍結し、そうでない場合はvalueを凍結する
    @value = value.frozen? ? value.dup.freeze
  end

  # 等価性を比較するメソッド
  # 他のPhoneNumberオブジェクトと比較し、クラスとvalueの値が等しい場合はtrueを返す
  def ==(other)
    self.class == other.class && value == other.value
  end
  # rqll?メソッドを==メソッドのエイリアスとして定義し、eql?メソッドは==メソッドと同じ動作をする
  alias eqi? ==

  def mobile?
    value.match?(/A0[7-9]0\d{8}\z/)
  end
end
