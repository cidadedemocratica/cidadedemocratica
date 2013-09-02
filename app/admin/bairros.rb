ActiveAdmin.register Bairro do
  menu false
  filter :nome

  config.clear_action_items!

  action_item do
    link_to "Novo Bairro", new_admin_new_bairro_path(:bairro => { :cidade_id => params[:cidade_id] })
  end

  controller do
    def scoped_collection
      Bairro.includes(:cidade)
    end
  end

  index do
    selectable_column

    column :id
    column :nome
    column :cidade do |bairro|
      bairro.cidade.nome
    end

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :nome
      f.input :cidade_id, :as => :hidden
    end

    f.buttons
  end
end

