ActiveAdmin.register Pais do
  menu :parent => "Localização", :priority => 0

  actions  :index

  index do
    selectable_column

    column :id
    column :nome
  end
end
