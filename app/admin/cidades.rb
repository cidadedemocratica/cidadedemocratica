ActiveAdmin.register Cidade do
  menu :parent => "Localização"

  controller do
    def scoped_collection
      Cidade.includes(:estado)
    end
  end

  index do
    selectable_column

    column :id
    column :nome
    column :bairros do |cidade|
      link_to "Ver Bairros", admin_new_bairros_path(:cidade_id => cidade)
    end

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :nome
      f.input :estado
    end

    f.buttons
  end
end
