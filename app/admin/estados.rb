ActiveAdmin.register Estado do
  menu :parent => "Localização", :priority => 1

  index do
    selectable_column

    column :id
    column :abrev
    column :nome

    default_actions
  end

  form do |f|
    f.inputs do
      f.input :nome
      f.input :abrev
    end

    f.buttons
  end
end
