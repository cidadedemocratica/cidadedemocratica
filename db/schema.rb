# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130410142602) do

  create_table "active_admin_comments", :force => true do |t|
    t.string   "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "adesoes", :force => true do |t|
    t.integer  "topico_id",  :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "adesoes", ["created_at"], :name => "index_adesoes_on_created_at"
  add_index "adesoes", ["topico_id", "user_id"], :name => "index_adesoes_on_topico_id_and_user_id", :unique => true
  add_index "adesoes", ["topico_id"], :name => "index_adesoes_on_topico_id"
  add_index "adesoes", ["user_id"], :name => "index_adesoes_on_user_id"

  create_table "bairros", :force => true do |t|
    t.string   "nome"
    t.integer  "cidade_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "relevancia", :default => 0
  end

  add_index "bairros", ["cidade_id", "nome"], :name => "index_bairros_on_cidade_id_and_nome"
  add_index "bairros", ["relevancia"], :name => "index_bairros_on_relevancia"

  create_table "cidades", :force => true do |t|
    t.string   "nome"
    t.integer  "estado_id"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "relevancia", :default => 0
  end

  add_index "cidades", ["estado_id", "nome"], :name => "index_cidades_on_estado_id_and_nome"
  add_index "cidades", ["relevancia"], :name => "index_cidades_on_relevancia"
  add_index "cidades", ["slug"], :name => "index_cidades_on_slug"

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",                       :default => 0
    t.string   "commentable_type", :limit => 15,       :default => ""
    t.text     "body",             :limit => 16777215
    t.integer  "user_id",                              :default => 0,  :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "tipo",             :limit => 20,       :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["id", "commentable_type", "commentable_id"], :name => "index_comments_on_id_and_commentable_type_and_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "competition_prizes", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "competition_id"
    t.integer  "offerer_id"
    t.integer  "winning_topic_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "competitions", :force => true do |t|
    t.string   "short_description"
    t.boolean  "published",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "start_date"
    t.integer  "inspiration_phase"
    t.integer  "proposals_phase"
    t.integer  "support_phase"
    t.integer  "joining_phase"
    t.integer  "announce_phase"
    t.string   "title"
    t.string   "image"
    t.integer  "current_phase_cd"
    t.text     "long_description"
    t.text     "author_description"
    t.text     "regulation"
    t.text     "awards"
    t.text     "partners"
    t.boolean  "finished",           :default => false
  end

  create_table "estados", :force => true do |t|
    t.string   "nome"
    t.string   "abrev"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "relevancia", :default => 0
  end

  add_index "estados", ["abrev"], :name => "index_estados_on_abrev"
  add_index "estados", ["relevancia"], :name => "index_estados_on_relevancia"

  create_table "historico_de_logins", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.string   "ip"
  end

  add_index "historico_de_logins", ["created_at"], :name => "index_historico_de_logins_on_created_at"
  add_index "historico_de_logins", ["user_id"], :name => "index_historico_de_logins_on_user_id"

  create_table "imagens", :force => true do |t|
    t.integer  "responsavel_id"
    t.string   "responsavel_type"
    t.integer  "size"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "position"
    t.string   "legenda"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "imagens", ["responsavel_id", "responsavel_type"], :name => "by_responsavel_id_and_type"

  create_table "inspirations", :force => true do |t|
    t.integer  "competition_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image"
    t.integer  "user_id"
    t.string   "title"
  end

  create_table "joining_topic_topicos", :force => true do |t|
    t.integer  "joining_topic_id"
    t.integer  "topico_id"
    t.string   "kind"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "joining_topic_topicos", ["joining_topic_id"], :name => "index_joining_topic_topicos_on_joining_topic_id"
  add_index "joining_topic_topicos", ["topico_id"], :name => "index_joining_topic_topicos_on_topico_id"

  create_table "joining_topics", :force => true do |t|
    t.integer  "current_phase_cd"
    t.string   "title"
    t.text     "description"
    t.text     "observation"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "user_id"
    t.integer  "author_id"
  end

  add_index "joining_topics", ["user_id"], :name => "index_joining_topics_on_user_id"

  create_table "links", :force => true do |t|
    t.string   "nome"
    t.string   "url"
    t.integer  "position"
    t.integer  "topico_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "links", ["topico_id", "position"], :name => "index_links_on_topico_id_and_position"

  create_table "locais", :force => true do |t|
    t.integer  "responsavel_id"
    t.string   "responsavel_type"
    t.integer  "bairro_id"
    t.integer  "cidade_id"
    t.decimal  "lat",                            :precision => 15, :scale => 10
    t.decimal  "lng",                            :precision => 15, :scale => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "cep",              :limit => 10
    t.integer  "estado_id"
    t.integer  "pais_id"
  end

  add_index "locais", ["bairro_id"], :name => "index_locais_on_bairro_id"
  add_index "locais", ["cidade_id"], :name => "index_locais_on_cidade_id"
  add_index "locais", ["estado_id"], :name => "index_locais_on_estado_id"
  add_index "locais", ["pais_id"], :name => "index_locais_on_pais_id"
  add_index "locais", ["responsavel_id", "responsavel_type"], :name => "index_locais_on_responsavel_id_and_responsavel_type"

  create_table "macro_tags", :force => true do |t|
    t.string   "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "nings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "source_id"
    t.string   "owner_id"
    t.string   "apps_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "observatorios", :force => true do |t|
    t.integer  "user_id"
    t.string   "nome"
    t.boolean  "receber_email", :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "observatorios", ["user_id"], :name => "index_observatorios_on_user_id"

  create_table "observatorios_tem_tags", :id => false, :force => true do |t|
    t.integer "observatorio_id"
    t.integer "tag_id"
  end

  add_index "observatorios_tem_tags", ["observatorio_id", "tag_id"], :name => "index_observatorios_tem_tags_on_observatorio_id_and_tag_id", :unique => true

  create_table "paises", :force => true do |t|
    t.string   "iso",        :limit => 2
    t.string   "nome"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plugin_schema_migrations", :id => false, :force => true do |t|
    t.string "plugin_name"
    t.string "version"
  end

  create_table "seguidos", :force => true do |t|
    t.integer  "topico_id",  :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "seguidos", ["user_id", "topico_id"], :name => "index_seguidos_on_user_id_and_topico_id", :unique => true

  create_table "sessions", :force => true do |t|
    t.string   "session_id",                     :null => false
    t.text     "data",       :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string   "var",                            :null => false
    t.text     "value",      :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["var"], :name => "index_settings_on_var"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type", :limit => 20
    t.string   "context",       :limit => 40
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "tag_tag_tag_context"
  add_index "taggings", ["taggable_id", "taggable_type", "tag_id", "context"], :name => "index_taggings_on_keys"

  create_table "tags", :force => true do |t|
    t.string  "name"
    t.integer "relevancia", :default => 0
  end

  add_index "tags", ["name"], :name => "index_tags_on_name"
  add_index "tags", ["relevancia"], :name => "index_tags_on_relevancia"

  create_table "temas", :force => true do |t|
    t.string   "nome"
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "temas", ["slug"], :name => "index_temas_on_slug"

  create_table "temas_topicos", :id => false, :force => true do |t|
    t.integer "tema_id",   :null => false
    t.integer "topico_id", :null => false
  end

  add_index "temas_topicos", ["topico_id", "tema_id"], :name => "index_temas_topicos_on_topico_id_and_tema_id", :unique => true

  create_table "topicos", :force => true do |t|
    t.string   "type",             :limit => 20
    t.integer  "user_id",                                             :null => false
    t.string   "titulo"
    t.text     "descricao",        :limit => 16777215
    t.text     "complementar",     :limit => 16777215
    t.integer  "parent_id"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comments_count",                       :default => 0
    t.integer  "adesoes_count",                        :default => 0
    t.integer  "relevancia",                           :default => 0
    t.integer  "seguidores_count",                     :default => 0
    t.string   "site"
    t.integer  "competition_id"
  end

  add_index "topicos", ["adesoes_count"], :name => "index_topicos_on_adesoes_count"
  add_index "topicos", ["comments_count"], :name => "index_topicos_on_comments_count"
  add_index "topicos", ["parent_id"], :name => "index_topicos_on_parent_id"
  add_index "topicos", ["relevancia"], :name => "index_topicos_on_relevancia"
  add_index "topicos", ["seguidores_count"], :name => "index_topicos_on_seguidores_count"
  add_index "topicos", ["slug"], :name => "index_topicos_on_slug"
  add_index "topicos", ["type"], :name => "index_topicos_on_type"
  add_index "topicos", ["user_id"], :name => "index_topicos_on_user_id"

  create_table "user_authorizations", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_authorizations", ["provider"], :name => "index_user_authorizations_on_provider"
  add_index "user_authorizations", ["uid"], :name => "index_user_authorizations_on_uid"

  create_table "user_dados", :force => true do |t|
    t.integer  "user_id",                                              :null => false
    t.string   "nome",             :limit => 100
    t.string   "fone",             :limit => 20
    t.string   "email_de_contato", :limit => 60
    t.string   "site_url"
    t.text     "descricao",        :limit => 16777215
    t.string   "sexo",             :limit => 1,        :default => ""
    t.date     "aniversario"
    t.string   "fax",              :limit => 20
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_dados", ["nome"], :name => "index_user_dados_on_nome"
  add_index "user_dados", ["user_id"], :name => "index_user_dados_on_user_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login",                     :limit => 100
    t.string   "name",                      :limit => 100, :default => ""
    t.string   "email",                     :limit => 100
    t.string   "encrypted_password",        :limit => 128, :default => "",        :null => false
    t.string   "password_salt",                            :default => "",        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.string   "state",                                    :default => "passive"
    t.datetime "deleted_at"
    t.string   "type",                      :limit => 20
    t.integer  "parent_id"
    t.string   "slug"
    t.integer  "topicos_count",                            :default => 0
    t.integer  "comments_count",                           :default => 0
    t.integer  "adesoes_count",                            :default => 0
    t.integer  "relevancia",                               :default => 0
    t.datetime "confirmation_sent_at"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                            :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "inspirations_count"
  end

  add_index "users", ["adesoes_count"], :name => "index_users_on_adesoes_count"
  add_index "users", ["comments_count"], :name => "index_users_on_comments_count"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["login"], :name => "index_users_on_login", :unique => true
  add_index "users", ["parent_id"], :name => "index_users_on_parent_id"
  add_index "users", ["relevancia"], :name => "index_users_on_relevancia"
  add_index "users", ["slug"], :name => "index_users_on_slug"
  add_index "users", ["state"], :name => "users_state", :length => {"state"=>12}
  add_index "users", ["topicos_count"], :name => "index_users_on_topicos_count"
  add_index "users", ["type"], :name => "index_users_on_type"

end
