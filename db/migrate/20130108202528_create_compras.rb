class CreateCompras < ActiveRecord::Migration
  def change
    create_table :compras do |t|
      t.string :id_transacao
      t.integer :valor
      t.integer :status_pagamento
      t.string :cod_moip
      t.integer :forma_pagamento
      t.string :tipo_pagamento
      t.integer :parcelas
      t.integer :usuario_id

      t.timestamps
    end
  end
end
