ActiveAdmin.register Comment, :as => "Comentarios dos topicos" do
  menu :parent => "Tópicos", :priority => 2
  actions :all, :except => [:new, :create, :edit, :update]

  csv do
    column :id
    column :body
    column :tipo do |c|
      c.tipo.capitalize
    end
    column :user do |c|
      c.user.nome
    end
    column :topico do |c|
      c.commentable.titulo if c.commentable_type == "Topico"
    end
  end

  index do
    selectable_column

    column :id
    column :body
    column :tipo do |c|
      c.tipo.capitalize
    end
    column :user do |c|
      link_to c.user.nome, admin_new_user_path(c.user)
    end

    default_actions
  end

  show do |c|
    attributes_table do
      row :id
      row :body
      row :topico do
        link_to c.commentable.titulo, admin_new_topico_path(c.commentable)
      end if c.commentable_type == "Topico"
      row :user
      row :created_at
      row :updated_at
    end

    active_admin_comments
  end

  filter :body
  filter :tipo
  filter :created_at
end
