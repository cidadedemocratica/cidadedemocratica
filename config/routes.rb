Rails.application.routes.draw do

  # Letter opener
  if Rails.env.development? or Rails.env.staging?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # Configurações
  types_of_topico       = Regexp.new("(topicos|#{Topico::TYPES.map(&:last).map(&:tableize).join('|')})")
  orders_of_topico      = Regexp.new("(#{Topico::ORDERS.join('|')})")
  feeds_of_topico       = Regexp.new("(#{Topico::FEEDS.join('|')})")

  types_of_user         = Regexp.new("(#{User::TYPES.map(&:last).map(&:tableize).join('|')})")
  orders_of_user        = Regexp.new("(#{User::ORDERS.join('|')})")

  estado = Regexp.new('[a-z]{2}')
  cidade = Regexp.new('[a-zA-Z\-]+')

  match "/*robots.txt", :to => redirect("/robots.txt")

  #=================================================#
  #  Admin
  #=================================================#
  match "/admin", :to => "admin/painel#index", :as => "admin"

  namespace :admin do

    resources :macro_tags

    resources :tags do
      collection do
        get :maistags
        post :set_tag_name
        post :novastags
        get :transferencia
        post :transferencia_post
        post :transfere_drag
        match :separar
      end
    end
    resources :topicos do
      member do
        post :comment_destroy
      end
    end
    resources :configuracoes do
      collection do
        get :update_check_box
        post :salvar
      end
    end
    resources :comentarios
  end

  #=============================================================================================#
  #  Aplicação para o USUÁRIO: Login, logout, cadastro, confirmação, perfil, observatorio etc.
  #=============================================================================================#

  devise_for :users,
    :controllers => {
      :registrations => "devise/custom/registrations",
      :passwords => "devise/custom/passwords",
      :sessions => "devise/custom/sessions",
      :omniauth_callbacks => "omniauth_callbacks"
    }

  match "/usuario/completar_cadastro" => "users#complete", :as => "completar_cadastro"
  match "/vincular/:user_id_criptografado" => "users#vincular", :as => "vincular"
  match "/solicitar_vinculacao/:organizacao_id" => "users#solicitar_vinculacao", :as => "solicitar_vinculacao"
  match "/usuarios/solicitar_cadastro_entidade" => "users#solicitar_cadastro_entidade", :as => "solicitar_cadastro_entidade"
  match "/users/:id/waiting_for_confirmation" => "users#waiting_for_confirmation", :as => "waiting_for_confirmation"
  match "/users/save" => "users#save"

  # Navegação por usuários
  match "/usuarios(/:user_type)(/estado/:estado_abrev)(/cidade/:cidade_slug)(/bairro/:bairro_id)(/:order)" => "users#index",
    :constraints => {
      :user_type => types_of_user,
      :estado_abrev => estado,
      :cidade_slug => cidade,
      :bairro_id => /\d+/,
      :order => orders_of_user
    },
    :as => "usuarios"

  # Perfil do usuário: dados pessoais, local, avatar, tópicos, comentários, funcionários, etc.
  match "/perfil/:id" => "users#show", :constraints => { :id => /\d+/ }, :as => "perfil"
  match "/perfil/:id.:format" => "users#show", :constraints => { :id => /\d+/ }, :as => "perfil_rss"
  match "/perfil/:id.:format" => "users#show", :constraints => { :id => /\d+/ }, :as => "perfil_json"
  match "/perfil/:id/mensagem" => "users#mensagem", :constraints => { :id => /\d+/ }, :as => "perfil_mensagem"

  match "/perfil/:id/propostas" => "users#show", :type => "propostas", :constraints => { :id => /\d+/ }, :as => "perfil_propostas"
  match "/perfil/:id/problemas" => "users#show", :type => "problemas", :constraints => { :id => /\d+/ }, :as => "perfil_problemas"
  match "/perfil/:id/comentarios" => "users#show", :type => "comments", :constraints => { :id => /\d+/ }, :as => "perfil_comentarios"
  match "/perfil/:id/apoios" => "users#show", :type => "adesoes", :constraints => { :id => /\d+/ }, :as => "perfil_apoios"
  match "/perfil/:id/seguindo" => "users#show", :type => "seguidos", :constraints => { :id => /\d+/ }, :as => "perfil_seguindo"

  match "/perfil/dados_basicos" => "users#edit", :as => "edit_user"
  match "/perfil/localizacao" => "users#localizacao"
  match "/perfil/avatar" => "avatar#new", :as => "new_avatar"
  match "/perfil/avatar/resize" => "avatar#resize"
  match "/perfil/avatar/salvar" => "avatar#create"
  match "/perfil/avatar/remover" => "avatar#destroy"
  match "/perfil/descadastrar" => "users#descadastrar", :as => "descadastrar"
  match "/perfil/confirma_descadastro" => "users#confirma_descadastro", :as => "confirma_descadastro"

  # Meu Observatório
  match "/meu-observatorio/novo" => "observatorios#new", :as => "novo_observatorio"
  match "/meu-observatorio/criar" => "observatorios#create", :as => "criar_observatorio"
  match "/meu-observatorio/editar" => "observatorios#edit", :as => "editar_observatorio"
  match "/meu-observatorio/salvar" => "observatorios#salvar", :as => "salvar_observatorio"
  match "/meu-observatorio/comentarios(/:page)" => "observatorios#comentarios", :as => "observatorio_comentarios"
  match "/meu-observatorio/apoios(/:page)" => "observatorios#apoios", :as => "observatorio_apoios"
  match "/meu-observatorio(/:page)" => "observatorios#index", :as => "observatorio"
  match "/meu-observatorio/:action/:id" => "observatorios"

  #==============================================#
  #   Tópicos
  #==============================================#

  match "/:topico_type(/estado/:estado_abrev)(/cidade/:cidade_slug)(/bairro/:bairro_id)(/tags/:tag_id)(/de/:user_type)(/:order(/:rss))(/:page)" => "topicos#index",
    :constraints => {
      :topico_type  => types_of_topico,
      :estado_abrev => estado,
      :cidade_slug  => cidade,
      :bairro_id    => /\d+/,
      :tag_id       => /\d+/,
      :user_type    => types_of_user,
      :order        => orders_of_topico,
      :rss          => feeds_of_topico,
      :page         => /\d+/
    },
    :defaults => {
      :topico_type => "topicos"
    },
    :as => "topicos"

  match "/topicos/mostrar_similares" => "topicos#mostrar_similares", :as => "topico_mostrar_similares"

  # Novo tópico
  match "/topicos/criar/:type" => "topicos#new", :via => :get, :as => "novo_topico"
  match "/topicos/criar/:type/localizar" => "topicos#new_localizar", :via => :post, :as => "localizar_novo_topico"
  match '/competitions/:competition_id/proposal/new' => 'topicos#new', :type => "proposta", :as => :new_competition_proposal
  match "/topicos/salvar" => "topicos#create", :as => "criar_topico"

  # Tópico
  match "/topico/:topico_slug" => "topicos#show", :as => "topico"
  match "/topico/:topico_slug/editar" => "topicos#edit", :as => "editar_topico"
  match "/topico/:topico_slug/salvar" => "topicos#update", :as => "salvar_topico"

  match "/topico/:topico_slug/aderir" => "topicos#aderir", :as => "aderir"
  match "/topico/:topico_slug/seguir" => "topicos#seguir", :as => "seguir"

  # Localização de tópico
  match "/topico/:topico_slug/localizacao" => "topicos#localizacao", :as => "topico_localizacao"

  # Editar Tags de tópico
  match "/topico/:topico_slug/tags" => "topicos#tags", :as => "topico_localizacao"
  match "/topico/:topico_slug/tags_by_link" => "topicos#tags_by_link", :as => "topico_localizacao"

  # Imagens de tópico
  match "/topico/:topico_slug/imagens" => "imagens#index", :as => "topico_imagens"
  match "/topico/:topico_slug/imagens/nova" => "imagens#create", :as => "topico_nova_imagem"
  match "/topico/:topico_slug/imagens/editar/:id" => "imagens#edit", :as => "topico_editar_imagem"
  match "/topico/:topico_slug/imagens/remover/:id" => "imagens#destroy", :as => "topico_remover_imagem"

  # Links de tópico
  match "/topico/:topico_slug/links" => "links#index", :as => "topico_links"
  match "/topico/:topico_slug/links/novo" => "links#create", :as => "topico_novo_link"
  match "/topico/:topico_slug/links/remover/:id" => "links#destroy", :as => "topico_remover_link"

  # Denunciar
  match "/topico/:topico_slug/denunciar" => "topicos#denunciar", :as => "topico_denunciar"

  # Comments
  match "/comments/processar" => "comments#processar", :as => "processar_comment"
  match "/comments/create" => "comments#create", :as => "create_comment"
  match "/comments/set_comentario_body/:id" => "comments#set_comentario_body"

  #======================================#
  #  Competitions
  #======================================#
  get '/competitions/:id(/fase/:phase(/tags/:tag_id))(/:order)(/page/:page)' => 'competitions#show',
    :constraints => CompetitionConstraint, :as => :competition

  resources :competitions, :only => [:index] do
    resources :inspirations

    member do
      get 'regulation'
      get 'prizes'
      get 'partners'
    end
  end

  #======================================#
  #  Joining Topics
  #======================================#
  match "/joining_topics/new/:topico_id", :controller => "joining_topics", :action => "new",
    :constraints => {:topico_id => /\d+/},
    :as => :new_joining_topic

  resources :joining_topics, :only => [:show, :create] do
    member do
      get :preview

      get :title_edit
      put :title_update

      get :description_edit
      put :description_update

      put :suggest
      put :reject
      put :aprove
    end
  end

  #======================================#
  #  General
  #======================================#

  # Tags
  match "/tags/auto_complete_responder" => "tags#auto_complete_responder", :as => "auto_complete_responder_tags"

  # Busca do Google
  match "/busca-google" => "busca#index", :as => "busca_google"

  # Static pages
  match "/static_pages/:name" => 'static_pages#show', :as => :static_page, :format => false

  # Locais
  match "/locais/cidades_li_for_ul" => "locais#cidades_li_for_ul"
  match "/locais/bairros_li_for_ul" => "locais#bairros_li_for_ul"
  match "/locais/cidades_options_for_select(/:first_option)" => "locais#cidades_options_for_select", :as => :cidades_options_for_select
  match "/locais/bairros_options_for_select(/:first_option)" => "locais#bairros_options_for_select", :as => :bairros_options_for_select

  # Conteúdos estáticos
  match "/tour" => "home#tour", :as => "tour"
  match "/fale-conosco" => "home#fale_conosco", :as => "fale_conosco"

  # Lista todos as cidades e estados
  match "/cidades" => "locais#cidades", :as => "cidades"
  match "/temas" => "home#temas", :as => "temas"

  # Raiz do site
  root :to => 'home#index'

  # Active Admin
  ActiveAdmin.routes(self)
end
