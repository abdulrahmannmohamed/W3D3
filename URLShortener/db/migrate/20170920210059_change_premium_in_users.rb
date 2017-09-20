class ChangePremiumInUsers < ActiveRecord::Migration[5.1]
  def change
    change_column :users, :premium, :boolean, default: false, null: false
  end
end
