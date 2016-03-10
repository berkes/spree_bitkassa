class CreateBitkassaTransactions < ActiveRecord::Migration
  def change
    create_table :spree_bitkassa_transactions do |t|
      t.references :payment, index: true
      t.string :bitkassa_payment_id, index: true
      t.string :address
      t.integer :amount
      t.integer :expire

      t.timestamps(null: false)
    end
  end
end
