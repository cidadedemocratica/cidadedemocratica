ActiveAdmin.register JoiningTopic do
  menu :parent => "Concursos", :priority => 3
  actions :index, :show, :destroy

  scope :all, :default => true
  scope :without_autor do |joining_topic|
    joining_topic.where(:current_phase_cd => joining_topic.propose_phase)
  end

  index do
    selectable_column

    column :id
    column :human_current_phase, :sortable => :current_phase_cd
    column :author do |joining_topic|
      if joining_topic.author.present?
        joining_topic.author.nome
      else
        link_to(I18n.t('active_admin.attribute_author'), attribute_author_edit_admin_new_joining_topic_path(joining_topic))
      end
    end
    column :topico do |joining_topic|
      link_to truncate(joining_topic.topicos_from[0].titulo, :length => 50), admin_new_topico_path(joining_topic.topicos_from[0])
    end
    column :topico_joined do |joining_topic|
      link_to truncate(joining_topic.topicos_from[1].titulo, :length => 50), admin_new_topico_path(joining_topic.topicos_from[1])
    end
    column :topico_to do |joining_topic|
      if joining_topic.topico_to
        link_to truncate(joining_topic.topico_to.titulo, :length => 50), admin_new_topico_path(joining_topic.topico_to)
      else
        "-"
      end
    end

    default_actions
  end

  show do |joining_topic|
    attributes_table do
      row :id
      row :human_current_phase
      row :topico do
        link_to joining_topic.topicos_from[0].titulo, admin_new_topico_path(joining_topic.topicos_from[0])
      end
      row :topico_joined do
        link_to joining_topic.topicos_from[1].titulo, admin_new_topico_path(joining_topic.topicos_from[1])
      end
      row :user do
        link_to joining_topic.user.nome, admin_new_user_path(joining_topic.user)
      end
    end

    attributes_table do
      row :title
      row :description
      row :author do
        if joining_topic.author.present?
          link_to joining_topic.author.nome, admin_new_user_path(joining_topic.author)
        else
          'autor não escolhido'
        end
      end
      row :topico_to do
        if joining_topic.topico_to
          link_to joining_topic.topico_to.titulo, admin_new_topico_path(joining_topic.topico_to)
        else
          "-"
        end
      end
    end

    active_admin_comments
  end

  # attribute_author

  member_action :attribute_author_edit do
    @joining_topic = resource
  end

  member_action :attribute_author_update, :method => :put do
    @joining_topic = resource
    if params[:joining_topic][:author_id].present?
      @joining_topic.author_id = params[:joining_topic][:author_id]
      @joining_topic.current_phase = :author_phase
      @joining_topic.save!

      JoiningTopicMailer.attributed_author(@joining_topic.id).deliver

      redirect_to :action => :show, :id => @joining_topic.id
    else
      flash[:error] = "Você deve escolher um autor"
      redirect_to :action => :attribute_author_edit, :id => @joining_topic.id
    end
  end

  action_item :only => :show do
    link_to(I18n.t('active_admin.attribute_author'), attribute_author_edit_admin_new_joining_topic_path(joining_topic))
  end


  filter :created_at
end
