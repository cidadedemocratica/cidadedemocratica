ActiveAdmin.register Inspiration do
  menu :parent => "Concursos", :priority => 2
  actions :all, :except => [:new]

  form :html => { :multipart => true } do |f|
    f.inputs 'Dados básicos' do
      f.input :title
      f.input :description
    end

    f.inputs 'Imagem' do
      if f.object.image?
        f.input :image, :hint => image_tag(f.object.image.url(:small))
      else
        f.input :image
      end
      f.input :image_cache, :as => :hidden
    end

    f.buttons
  end

  show do |inspiration|
    attributes_table do
      row :title
      row :description

      if inspiration.image?
        row :image do
          image_tag inspiration.image.url(:small)
        end
      end
    end

    active_admin_comments
  end

  index do
    selectable_column

    column :id
    column :image do |inspiration|
      if inspiration.image?
        image_tag inspiration.image.url(:small)
      end
    end
    column :title
    column :description

    default_actions
  end

  filter :competition
  filter :title
  filter :description
  filter :created_at
end
