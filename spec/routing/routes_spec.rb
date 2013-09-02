require 'spec_helper'

describe "main routes" do
  it "should validate the root" do
    expect( :get => "/").to route_to(:controller => "home", :action => "index")
  end

  it "should validate main user registration routes" do
    expect( :get => "/usuario/completar_cadastro").to route_to(:controller => "users", :action => "complete")
  end

  it "should validate users routes" do
    expect( :get => "/vincular/1234" ).to route_to(:controller => "users", :action => "vincular", :user_id_criptografado => "1234")
    expect( :get => "/solicitar_vinculacao/1234" ).to route_to(:controller => "users", :action => "solicitar_vinculacao", :organizacao_id => "1234")
    expect( :get => "/perfil/1234" ).to route_to(:controller => "users", :action => "show", :id => "1234")
    expect( :get => "/perfil/1234.rss" ).to route_to(:controller => "users", :action => "show", :id => "1234", :format => "rss")
    expect( :get => "/perfil/1234.json" ).to route_to(:controller => "users", :action => "show", :id => "1234", :format => "json")
    expect( :get => "/perfil/1234/mensagem" ).to route_to(:controller => "users", :action => "mensagem", :id => "1234")
    expect( :get => "/perfil/dados_basicos" ).to route_to(:controller => "users", :action => "edit")
    expect( :get => "/perfil/localizacao" ).to route_to(:controller => "users", :action => "localizacao")

    expect( :get => "/perfil/descadastrar" ).to route_to(:controller => "users", :action => "descadastrar")
    expect( :get => "/perfil/confirma_descadastro" ).to route_to(:controller => "users", :action => "confirma_descadastro")
  end

  it "should validate avatar routes" do
    expect( :get => "/perfil/avatar" ).to route_to(:controller => "avatar", :action => "new")
    expect( :get => "/perfil/avatar/resize" ).to route_to(:controller => "avatar", :action => "resize")
    expect( :post => "/perfil/avatar/salvar" ).to route_to(:controller => "avatar", :action => "create")
    expect( :delete => "/perfil/avatar/remover" ).to route_to(:controller => "avatar", :action => "destroy")
  end

  it "should validate general routes" do
    expect( :get => "/busca-google").to route_to(:controller => "busca", :action => "index")
    expect( :get => "/cidades").to route_to(:controller => "locais", :action => "cidades")
    expect( :get => "/temas").to route_to(:controller => "home", :action => "temas")

    expect( :get => "/static_pages/help").to route_to(:controller => "static_pages", :action => "show", :name => "help")
    expect( :get => "/tour").to route_to(:controller => "home", :action => "tour")
  end

  it "should validate observatorio routes" do
    expect( :get => "/meu-observatorio/novo").to route_to(:controller => "observatorios", :action => "new")
    expect( :post => "/meu-observatorio/criar").to route_to(:controller => "observatorios", :action => "create")
    expect( :post => "/meu-observatorio/salvar").to route_to(:controller => "observatorios", :action => "salvar")
    expect( :get => "/meu-observatorio/editar").to route_to(:controller => "observatorios", :action => "edit")
    expect( :get => "/meu-observatorio/comentarios").to route_to(:controller => "observatorios", :action => "comentarios")
    expect( :get => "/meu-observatorio/comentarios/123").to route_to(:controller => "observatorios", :action => "comentarios", :page => "123")
    expect( :get => "/meu-observatorio/apoios").to route_to(:controller => "observatorios", :action => "apoios")
    expect( :get => "/meu-observatorio/apoios/123").to route_to(:controller => "observatorios", :action => "apoios", :page => "123")
    expect( :get => "/meu-observatorio").to route_to(:controller => "observatorios", :action => "index")
    expect( :get => "/meu-observatorio/show/123").to route_to(:controller => "observatorios", :action => "show", :id => "123")
  end

  it "should validate user filters routes" do
  # Navegação por usuários: com todos os parametros
    expect( :get => "/usuarios/cidadaos/estado/sp/cidade/saopaulo/bairro/123/relevancia").
      to route_to( :controller => "users", :action => "index", :user_type => "cidadaos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :order => "relevancia")
    expect( :get => "/usuarios/gestores_publicos/estado/sp/cidade/saopaulo/bairro/123").to route_to( :controller => "users", :action => "index",
      :user_type => "gestores_publicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123")
  # Na cidade...
    expect( :get => "/usuarios/empresas/estado/sp/cidade/saopaulo/recentes").to route_to( :controller => "users", :action => "index",
      :user_type => "empresas", :estado_abrev => "sp", :cidade_slug => "saopaulo", :order => "recentes")
    expect( :get => "/usuarios/ongs/estado/sp/cidade/saopaulo").to route_to( :controller => "users", :action => "index",
      :user_type => "ongs", :estado_abrev => "sp", :cidade_slug => "saopaulo")

    expect( :get => "/usuarios/estado/sp/cidade/saopaulo/recentes").to route_to( :controller => "users", :action => "index",
      :estado_abrev => "sp", :cidade_slug => "saopaulo", :order => "recentes")
    expect( :get => "/usuarios/estado/sp/cidade/saopaulo").to route_to( :controller => "users", :action => "index",
      :estado_abrev => "sp", :cidade_slug => "saopaulo")

  # No estado...
    expect( :get => "/usuarios/poderes_publicos/estado/sp/mais_topicos").to route_to( :controller => "users", :action => "index",
      :user_type => "poderes_publicos", :estado_abrev => "sp", :order => "mais_topicos")
    expect( :get => "/usuarios/parlamentares/estado/sp").to route_to( :controller => "users", :action => "index",
      :user_type => "parlamentares", :estado_abrev => "sp" )

    expect( :get => "/usuarios/estado/sp/mais_topicos").to route_to( :controller => "users", :action => "index",
      :estado_abrev => "sp", :order => "mais_topicos")
    expect( :get => "/usuarios/estado/sp").to route_to( :controller => "users", :action => "index",
      :estado_abrev => "sp" )

  # Apenas separando os tipos...
    expect( :get => "/usuarios/universidades/mais_comentarios").to route_to( :controller => "users", :action => "index",
      :user_type => "universidades", :order => "mais_comentarios")
    expect( :get => "/usuarios/movimentos").to route_to( :controller => "users", :action => "index",
      :user_type => "movimentos" )

  # Em todo o site...
    expect( :get => "/usuarios/mais_apoios").to route_to( :controller => "users", :action => "index",
      :order => "mais_apoios")
    expect( :get => "/usuarios").to route_to( :controller => "users", :action => "index" )
  end

  it "should not validate based on the parameter constraints for the user filters" do
    # invalid user_type
    expect( :get => "/usuarios/xpto/estado/sp/cidade/saopaulo/bairro/123/relevancia").
      not_to route_to( :controller => "users", :action => "index", :user_type => "xpto", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :order => "relevancia")
    # invalid estado
    expect( :get => "/usuarios/cidadaos/estado/xpto/cidade/saopaulo/bairro/123/relevancia").
      not_to route_to( :controller => "users", :action => "index", :user_type => "cidadaos", :estado_abrev => "xpto", :cidade_slug => "saopaulo", :bairro_id => "123", :order => "relevancia")
    # invalid cidade
    expect( :get => "/usuarios/cidadaos/estado/sp/cidade/sao@paulo/bairro/123/relevancia").
      not_to route_to( :controller => "users", :action => "index", :user_type => "cidadaos", :estado_abrev => "sp", :cidade_slug => "sao@paulo", :bairro_id => "123", :order => "relevancia")
    # invalid bairro
    expect( :get => "/usuarios/cidadaos/estado/sp/cidade/saopaulo/bairro/xpto/relevancia").
      not_to route_to( :controller => "users", :action => "index", :user_type => "cidadaos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "xpto", :order => "relevancia")
    # invalid order
    expect( :get => "/usuarios/cidadaos/estado/sp/cidade/saopaulo/bairro/123/xpto").
      not_to route_to( :controller => "users", :action => "index", :user_type => "cidadaos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :order => "xpto")
  end

  it "should validate topico filters routes" do
  # Com todos os parametros
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/tags/456/de/cidadaos/relevancia/rss").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia", :rss => "rss")
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/tags/456/de/cidadaos/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia")
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/tags/456/de/cidadaos").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "456", :user_type => "cidadaos")

  # No bairro, com tema: SEM user_type ...
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/tags/456/recentes/rss").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "456", :order => "recentes", :rss => "rss")
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/tags/456/recentes").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "456", :order => "recentes")
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/tags/456/").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "456")

  # No bairro, por usuario/criador: SEM tag_id (mas COM user_type) ...
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/de/cidadaos/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :user_type => "cidadaos", :order => "relevancia")
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/de/cidadaos").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :user_type => "cidadaos")

  # No bairro apenas: SEM user_type e SEM tag_id ...
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/antigos").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :order => "antigos")
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123")

  # Na cidade, por tema e usuario/criador: SEM bairro_id (mas COM tag_id e COM user_type) ...
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/tags/456/de/cidadaos/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia")
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/tags/456/de/cidadaos").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :tag_id => "456", :user_type => "cidadaos")

  # Na cidade, por usuario/criador: SEM bairro_id e SEM tag_id (mas COM user_type) ...
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/de/cidadaos/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :user_type => "cidadaos", :order => "relevancia")
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/de/cidadaos").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :user_type => "cidadaos")

  # Na cidade, por tema: SEM bairro_id e SEM user_type (mas COM tag_id) ...
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/tags/456/relevancia/rss").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :tag_id => "456", :order => "relevancia", :rss => "rss")
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/tags/456/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :tag_id => "456", :order => "relevancia")
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/tags/456").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :tag_id => "456")

  # Na cidade apenas: SEM user_type, SEM tag_id, SEM bairro_id ...
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :order => "relevancia")
    expect( :get => "/topicos/estado/sp/cidade/saopaulo").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo")

  # No estado, por usuario/criador: SEM tag_id, SEM bairro_id, SEM cidade_id (mas COM user_type) ...
    expect( :get => "/topicos/estado/sp/de/cidadaos/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :user_type => "cidadaos", :order => "relevancia")
    expect( :get => "/topicos/estado/sp/de/cidadaos").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :user_type => "cidadaos")

  # No estado, por tema e usuario/criador: SEM bairro_id, SEM cidade_id (mas COM tag_id e COM user_type) ...
    expect( :get => "/topicos/estado/sp/tags/456/de/cidadaos/relevancia/rss").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia", :rss => "rss")
    expect( :get => "/topicos/estado/sp/tags/456/de/cidadaos/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia")
    expect( :get => "/topicos/estado/sp/tags/456/de/cidadaos").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :tag_id => "456", :user_type => "cidadaos")

  # No estado apenas: SEM user_type, SEM tag_id, SEM bairro_id, SEM cidade_slug ...
    expect( :get => "/topicos/estado/sp/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :order => "relevancia")
    expect( :get => "/topicos/estado/sp").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp")


  # Em todo o país, por tema e usuario/criado: COM user_type e COM tag_id ...
    expect( :get => "/topicos/tags/456/de/cidadaos/relevancia/rss").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia", :rss => "rss")
    expect( :get => "/topicos/tags/456/de/cidadaos/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia")
    expect( :get => "/topicos/tags/456/de/cidadaos").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :tag_id => "456", :user_type => "cidadaos")

  # Em todo o país, por tema: COM tag_id e SEM user_type ...
    expect( :get => "/topicos/de/cidadaos/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :user_type => "cidadaos", :order => "relevancia")
    expect( :get => "/topicos/de/cidadaos").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :user_type => "cidadaos")

  # Em todo o país, por usuario/criado: SEM user_type e COM tag_id ...
    expect( :get => "/topicos/tags/456/relevancia/rss").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :tag_id => "456", :order => "relevancia", :rss => "rss")
    expect( :get => "/topicos/tags/456/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :tag_id => "456", :order => "relevancia")
    expect( :get => "/topicos/tags/456").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :tag_id => "456")

  # Em todo o país...!
    expect( :get => "/topicos/relevancia").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :order => "relevancia")
    expect( :get => "/topicos").to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos")
  end

  it "should not validate based on the constraints of the topicos routes" do
    # invalid rss
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/tags/456/de/cidadaos/relevancia/xpto").not_to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia", :rss => "xpto")
    # invalid order
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/tags/456/de/cidadaos/xpto/rss").not_to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "456", :user_type => "cidadaos", :order => "xpto", :rss => "rss")
    # invalid user type
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/tags/456/de/xpto/relevancia/rss").not_to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "456", :user_type => "xpto", :order => "relevancia", :rss => "rss")
    # invalid tag
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/123/tags/xpto/de/cidadaos/relevancia/rss").not_to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "xpto", :user_type => "cidadaos", :order => "relevancia", :rss => "rss")
    # invalid bairro
    expect( :get => "/topicos/estado/sp/cidade/saopaulo/bairro/xpto/tags/456/de/cidadaos/relevancia/rss").not_to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "xpto", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia", :rss => "rss")
    # invalid cidade
    expect( :get => "/topicos/estado/sp/cidade/sao@@paulo/bairro/123/tags/456/de/cidadaos/relevancia/rss").not_to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "sp", :cidade_slug => "sao@@paulo", :bairro_id => "123", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia", :rss => "rss")
    # invalid estado
    expect( :get => "/topicos/estado/xpto/cidade/saopaulo/bairro/123/tags/456/de/cidadaos/relevancia/rss").not_to route_to( :controller => "topicos", :action => "index",
      :topico_type => "topicos", :estado_abrev => "xpto", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia", :rss => "rss")
    # invalid topico type
    expect( :get => "/xpto/estado/sp/cidade/saopaulo/bairro/123/tags/456/de/cidadaos/relevancia/rss").not_to route_to( :controller => "topicos", :action => "index",
      :topico_type => "xpto", :estado_abrev => "sp", :cidade_slug => "saopaulo", :bairro_id => "123", :tag_id => "456", :user_type => "cidadaos", :order => "relevancia", :rss => "rss")
  end

  it "should validate topicos routes" do
    expect( :get => "/topicos/criar/xpto").to route_to(:controller => "topicos", :action => "new", :type => "xpto")
    expect( :post => "/topicos/criar/xpto/localizar").to route_to(:controller => "topicos", :action => "new_localizar", :type => "xpto")

    expect( :get => "/topico/xpto").to route_to(:controller => "topicos", :action => "show", :topico_slug => "xpto")
    expect( :get => "/topico/xpto/editar").to route_to(:controller => "topicos", :action => "edit", :topico_slug => "xpto")
    expect( :put => "/topico/xpto/salvar").to route_to(:controller => "topicos", :action => "update", :topico_slug => "xpto")
    expect( :get => "/topico/xpto/aderir").to route_to(:controller => "topicos", :action => "aderir", :topico_slug => "xpto")
    expect( :get => "/topico/xpto/seguir").to route_to(:controller => "topicos", :action => "seguir", :topico_slug => "xpto")
    expect( :get => "/topico/xpto/localizacao").to route_to(:controller => "topicos", :action => "localizacao", :topico_slug => "xpto")
    expect( :get => "/topico/xpto/tags").to route_to(:controller => "topicos", :action => "tags", :topico_slug => "xpto")
    expect( :get => "/topico/xpto/tags_by_link").to route_to(:controller => "topicos", :action => "tags_by_link", :topico_slug => "xpto")
  end

  it "should validate topicos imagens routes" do
    expect( :get => "/topico/xpto/imagens").to route_to(:controller => "imagens", :action => "index", :topico_slug => "xpto")
    expect( :post => "/topico/xpto/imagens/nova").to route_to(:controller => "imagens", :action => "create", :topico_slug => "xpto")
    expect( :get => "/topico/xpto/imagens/editar/123").to route_to(:controller => "imagens", :action => "edit", :topico_slug => "xpto", :id => "123")
    expect( :delete => "/topico/xpto/imagens/remover/123").to route_to(:controller => "imagens", :action => "destroy", :topico_slug => "xpto", :id => "123")
  end

  it "should validate topicos links routes" do
    expect( :get => "/topico/xpto/links").to route_to(:controller => "links", :action => "index", :topico_slug => "xpto")
    expect( :post => "/topico/xpto/links/novo").to route_to(:controller => "links", :action => "create", :topico_slug => "xpto")
    expect( :delete => "/topico/xpto/links/remover/123").to route_to(:controller => "links", :action => "destroy", :topico_slug => "xpto", :id => "123")
  end

  it "should validate topicos denunciar routes" do
    expect( :delete => "/topico/xpto/denunciar").to route_to(:controller => "topicos", :action => "denunciar", :topico_slug => "xpto")
  end

  it "should validate competitions proposal routes" do
    expect( :get => "/competitions/123/proposal/new").to route_to(:controller => "topicos", :action => "new", :competition_id => "123", :type => 'proposta')
  end

  it "should validate competitions inspirations routes" do
    expect( :post => "/competitions/123/inspirations").to route_to(:controller => "inspirations", :action => "create", :competition_id => "123")
    expect( :get => "/competitions/123/inspirations/new").to route_to(:controller => "inspirations", :action => "new", :competition_id => "123")
    expect( :get => "/competitions/123/inspirations/456/edit").to route_to(:controller => "inspirations", :action => "edit", :competition_id => "123", :id => "456")
    expect( :get => "/competitions/123/inspirations/456").to route_to(:controller => "inspirations", :action => "show", :competition_id => "123", :id => "456")
    expect( :put => "/competitions/123/inspirations/456").to route_to(:controller => "inspirations", :action => "update", :competition_id => "123", :id => "456")
    expect( :delete => "/competitions/123/inspirations/456").to route_to(:controller => "inspirations", :action => "destroy", :competition_id => "123", :id => "456")
  end

  %w(tags topicos configuracoes comentarios).each do |resource|
    it "should validate old #{resource} admin routes" do
      expect( :get => "/admin/#{resource}").to route_to(:controller=>"admin/#{resource}", :action=>"index")
      expect( :post => "/admin/#{resource}").to route_to(:controller=>"admin/#{resource}", :action=>"create")
      expect( :get => "/admin/#{resource}/new").to route_to(:controller=>"admin/#{resource}", :action=>"new")
      expect( :get => "/admin/#{resource}/123/edit").to route_to(:controller=>"admin/#{resource}", :action=>"edit", :id => "123")
      expect( :get => "/admin/#{resource}/123").to route_to(:controller=>"admin/#{resource}", :action=>"show", :id => "123")
      expect( :put => "/admin/#{resource}/123").to route_to(:controller=>"admin/#{resource}", :action=>"update", :id => "123")
      expect( :delete => "/admin/#{resource}/123").to route_to(:controller=>"admin/#{resource}", :action=>"destroy", :id => "123")
    end
  end

  it "should validate old tags admin routes" do
    expect( :get => "/admin/tags/maistags").to route_to(:controller=>"admin/tags", :action=>"maistags")
    expect( :get => "/admin/tags/transferencia").to route_to(:controller=>"admin/tags", :action=>"transferencia")
    expect( :post => "/admin/tags/novastags").to route_to(:controller=>"admin/tags", :action=>"novastags")
    expect( :post => "/admin/tags/transferencia_post").to route_to(:controller=>"admin/tags", :action=>"transferencia_post")
  end
end

