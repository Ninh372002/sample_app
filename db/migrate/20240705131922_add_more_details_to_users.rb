class AddMoreDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :date_of_birth, :date
    add_column :users, :gender, :string
  end
end