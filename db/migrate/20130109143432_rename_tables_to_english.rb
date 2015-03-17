class RenameTablesToEnglish < ActiveRecord::Migration
  def up
  	rename_table :usuarios, :users
  	rename_column :users, :nome, :name
  	rename_column :users, :sobrenome, :last_name

  	rename_table :compras, :purchases
  	rename_column :purchases, :id_transacao, :id_transaction
  	rename_column :purchases, :valor, :amount
  	rename_column :purchases, :status_pagamento, :payment_status
  	rename_column :purchases, :cod_moip, :moip_code
  	rename_column :purchases, :forma_pagamento, :payment_method
  	rename_column :purchases, :tipo_pagamento, :payment_type
  	rename_column :purchases, :parcelas, :installments
  	rename_column :purchases, :usuario_id, :user_id

  	rename_column :authentications, :usuario_id, :user_id
  end

  def down
  	rename_table :users, :usuarios
  	rename_column :usuarios, :name, :nome
  	rename_column :usuarios, :last_name, :sobrenome

  	rename_table :purchases, :compras
  	rename_column :compras, :id_transaction, :comprasid_transacao
  	rename_column :compras, :amount, :valor
  	rename_column :compras, :payment_status, :status_pagamento
  	rename_column :compras, :moip_code, :cod_moip
  	rename_column :compras, :payment_method, :forma_pagamento
  	rename_column :compras, :payment_type, :tipo_pagamento
  	rename_column :compras, :installments, :parcelas
  	rename_column :compras, :user_id, :usuario_id

  	rename_column :authentications, :user_id, :usuario_id
  end
end