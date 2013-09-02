ActiveAdmin.register Competition do
  menu :parent => "Concursos", :priority => 1

  controller do
    def new
      new! do
        @competition.locais.build
        @competition.set_default_phases
        @competition.start_date = Time.now.to_date
      end
    end

    def create
      @competition = build_resource
      @competition.calculate_current_phase
      create!
    end

    def update
      update!
      resource.calculate_current_phase
      resource.save
    end
  end

  action_item :only => :show do
    link_to('Ver no site', competition_path(competition))
  end

  member_action :calculate_current_phase do
    competition = Competition.find(params[:id])
    competition.calculate_current_phase
    competition.save
    redirect_to :action => :show
  end

  member_action :publish do
    competition = resource
    competition.published = true
    if competition.save
      flash[:notice] = "Concurso publicado com sucesso."
      redirect_to :action => :show
    else
      flash[:notice] = "Não foi possível publicar o concurso. Verifique se todos os campos estão preenchidos."
      redirect_to :action => :show
    end
  end

  member_action :unpublish do
    competition = resource
    competition.published = false
    competition.save :validate => false
    flash[:notice] = "Concurso escondido com sucesso."
    redirect_to :action => :show
  end

  action_item :only => :show do
    link_to('Calcular fase atual', calculate_current_phase_admin_new_competition_path(competition))
  end

  action_item :only => :show do
    link_to('Publicar', publish_admin_new_competition_path(competition))
  end

  action_item :only => :show do
    link_to('Esconder', unpublish_admin_new_competition_path(competition))
  end

  action_item :only => :show do
    link_to 'Prêmios', admin_new_competition_competition_prizes_path(competition)
  end

  form :partial => 'form'

  show do |competition|
    attributes_table do
      row :title
      row :short_description
      row :long_description do
        markdown competition.long_description
      end
      row :author_description do
        markdown competition.author_description
      end
      row :human_current_phase

      row :start_date

      Competition::PHASES.each do |phase|
        row phase do
          expiration = pretty_format competition.before_expiration_time_from(phase)
          "#{competition.send phase} dias, até #{expiration}"
        end
      end

      row :finish_date do
        competition.expiration_date_from Competition::PHASES.last
      end

      row :regulation do
        markdown competition.regulation
      end

      row :awards do
        markdown competition.awards
      end

      row :partners do
        markdown competition.awards
      end

      row :published

      if competition.image?
        row :image do
          image_tag competition.image.url(:small)
        end
      end
    end

    panel "Locais" do
      table_for competition.locais do
        column :pais
        column :estado
        column :cidade
        column :bairro
      end
    end

    active_admin_comments
  end

  index do
    selectable_column

    column :id
    column :image do |competition|
      if competition.image?
        image_tag competition.image.url(:small)
      end
    end
    column :title
    column :prizes do |competition|
      link_to 'Prêmios', admin_new_competition_competition_prizes_path(competition)
    end
    column :short_description do |competition|
      truncate competition.short_description, :length => 100
    end
    column :human_current_phase

    column :start_date

    Competition::PHASES.each do |phase|
      column phase do |competition|
        "até #{pretty_format competition.before_expiration_time_from(phase)}"
      end
    end

    column :finish_date do |competition|
      pretty_format competition.expiration_date_from(Competition::PHASES.last)
    end

    column :published

    default_actions
  end

  filter :title
  filter :short_description
  filter :start_date
  filter :created_at
end
