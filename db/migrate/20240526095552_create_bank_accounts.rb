class CreateBankAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :bank_accounts do |t|
      t.decimal :balance
      t.string :currency

      t.timestamps
    end
  end
end
