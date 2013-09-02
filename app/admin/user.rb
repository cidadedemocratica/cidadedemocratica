ActiveAdmin.register User do
  menu :parent => "Usuários", :priority => 1

  actions :all, :except => [:new]

  csv do
    column :id
    column :nome
    column :email
    column :state
    column :nome_do_tipo
    column :created_at
    column :fone
    column :fax
    column :email_de_contato
    column :site_url
    column :descricao
    column :aniversario
    column :idade
    column :local do |user|
      user.local.descricao if user.local
    end

    column :relevancia
    column :topicos_count
    column :comments_count
    column :adesoes_count
    column :inspirations_count
  end

  index do
    selectable_column

    column :id
    column :nome
    column :email
    column :nome_do_tipo
    column :relevancia
    column :state

    default_actions
  end

  action_item :only => :show, :if => proc { user.state == 'pending' } do
    link_to 'Reenviar confirmação', resend_confirmation_email_admin_new_user_path(user)
  end

  show do |user|
    attributes_table do
      row :id
      row :nome
      row :email
      row :state
      row :nome_do_tipo
      row :created_at
      row :fone
      row :fax
      row :email_de_contato
      row :site_url
      row :descricao
      row :aniversario
      row :idade
      row :local do
        user.local.descricao if user.local
      end
    end

    attributes_table do
      row :relevancia
      row :topicos_count
      row :comments_count
      row :adesoes_count
      row :inspirations_count
    end

    active_admin_comments
  end

  form do |f|
    f.inputs do
      f.input :state, :collection => User::STATES
      f.input :type, :collection => User::TYPES
    end

    f.buttons
  end

  batch_action :resend_confirmation_email do |selection|
    User.find(selection).each do |user|
      UserMailer.signup_notification(user.id).deliver if user.state == 'pending'
    end
    flash[:notice] = "E-mails enviados com sucesso."
    redirect_to :action => :index
  end

  member_action :resend_confirmation_email do
    UserMailer.signup_notification(resource.id).deliver
    flash[:notice] = "E-mail enviado com sucesso."
    redirect_to :action => :show
  end


  filter :dado_nome, :as => "string"
  filter :email
  filter :type, :as => "select", :collection => User::TYPES
  filter :state, :as => "select", :collection => User::STATES
  filter :dado_sexo, :as => "select", :collection => User::GENRES
  filter :local_estado_id, :as => "select", :input_html => { :class => "estado_select_cascade" }, :collection => proc {
    Estado.order(:nome)
  }
  filter :local_cidade_id, :as => "select", :input_html => { :class => "cidade_select_cascade", "data-first_option" => "Qualquer" }, :collection => proc {
    Cidade.where(:estado_id => params[:q][:local_estado_id_eq]).order(:nome).map { |c| [c.nome, c.id] } rescue []
  }
  filter :local_bairro_id, :as => "select", :input_html => { :class => "bairro_select_cascade", "data-first_option" => "Qualquer" }, :collection => proc {
    Bairro.where(:cidade_id => params[:q][:local_cidade_id_eq]).order(:nome).map { |c| [c.nome, c.id] } rescue []
  }
  filter :created_at
end
