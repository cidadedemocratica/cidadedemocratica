ActiveAdmin.register Topico do
  menu :parent => "Tópicos", :priority => 1
  actions :all, :except => [:new]

  action_item :only => :show do
    link_to('Ver no site', topico_path(topico))
  end

  index do
    selectable_column

    column :id
    column :titulo
    column :relevancia
    column :type do |topic|
      topic.display_name
    end
    column :adesoes_count
    column :comments_count
    column :seguidores_count
    column :competition
    column :locais do |topic|
      topic.display_location
    end
    column :created_at

    default_actions
  end

  controller do
    def edit
      edit! { @topico.topico_type = @topico.type }
    end

    def update
      update! { @topico.update_attribute(:type, @topico.topico_type) }
    end
  end

  form do |f|
    f.inputs 'Dados básicos' do
      f.input :titulo
      f.input :topico_type, :as => :radio, :collection => %w( Problema Proposta )
      f.input :competition
      f.input :descricao
    end

    f.buttons
  end

  batch_action :assign_competition do |selection|
    redirect_to :action => :assign_competition, :params => { :ids => selection }
  end

  collection_action :assign_competition, :title => "Atribuir Concurso" do
    @topicos = Topico.find(params[:ids])
  end

  collection_action :update_competition, :method => :put do
    Topico.where(:id => params[:ids]).update_all(:competition_id => params[:topico][:competition_id])
    flash[:notice] = "Tópicos alterado com sucesso"
    redirect_to :action => :index
  end

  filter :titulo
  filter :competition, :collection => proc {
    [["Nenhum", 0]] + Competition.all.map { |c| [c.title, c.id] }
  }
  filter :type, :as => "select", :collection => Topico::TYPES
  filter :locais_estado_id, :as => "select", :input_html => { :class => "estado_select_cascade" }, :collection => proc {
    Estado.order(:nome)
  }
  filter :locais_cidade_id, :as => "select", :input_html => { :class => "cidade_select_cascade", "data-first_option" => "Qualquer" }, :collection => proc {
    Cidade.where(:estado_id => params[:q][:locais_estado_id_eq]).order(:nome).map { |c| [c.nome, c.id] } rescue []
  }
  filter :locais_bairro_id, :as => "select", :input_html => { :class => "bairro_select_cascade", "data-first_option" => "Qualquer" }, :collection => proc {
    Bairro.where(:cidade_id => params[:q][:locais_cidade_id_eq]).order(:nome).map { |c| [c.nome, c.id] } rescue []
  }
  filter :descricao
  filter :relevancia
end
