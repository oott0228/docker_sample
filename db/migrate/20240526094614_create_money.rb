class CreateMoney < ActiveRecord::Migration[7.1]
  def change
    create_table :money do |t|
      t.integer :amount
      t.integer :currency

      t.timestamps
    end
  end
end
