class CreateBankAccountMoneyTransfers < ActiveRecord::Migration[7.1]
  def change
    create_table :bank_account_money_transfers do |t|
      t.bigint :from_id
      t.string :to_id
      t.string :big_int
      t.decimal :amount
      t.string :currency

      t.timestamps
    end
  end
end
