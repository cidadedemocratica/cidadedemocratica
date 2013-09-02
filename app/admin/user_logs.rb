ActiveAdmin.register HistoricoDeLogin do
  menu :parent => "Usuários", :priority => 2

  actions :index

  index do
    selectable_column

    column :id
    column :created_at
    column :user
    column :ip
  end

  filter :created_at
end
