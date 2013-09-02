class User < ActiveRecord::Base
  include Authorization::StatefulRoles
  include Activities::User

  COUNTERS_TO_RELEVANCE = {
    "topicos_count"      => "user_relevancia_peso_topicos",
    "inspirations_count" => "user_relevancia_peso_inspiracoes",
    "comments_count"     => "user_relevancia_peso_comentarios",
    "adesoes_count"      => "user_relevancia_peso_apoios"
  }.freeze

  TYPES = [
    ["Cidadão", "Cidadao"],
    ["Gestor público", "GestorPublico"],
    ["Parlamentar", "Parlamentar"],
    ["ONG", "Ong"],
    ["Movimento", "Movimento"],
    ["Conferência", "Conferencia"],
    ["Empresa", "Empresa"],
    ["Poder público", "PoderPublico"],
    ["Igreja", "Igreja"],
    ["Universidade", "Universidade"],
    ["Outro tipo de organização", "Organizacao"],
    ["Administrador", "Admin"]
  ].freeze

  STATES = [
    ["Não confirmado", "pending"],
    ["Ativo", "active"],
    ["Banido", "suspended"],
    ["Apagado", "deleted"]
  ].freeze

  ORDERS = ["relevancia", "recentes", "mais_topicos", "mais_comentarios", "mais_apoios", "a-z", "z-a"].freeze
  GENRES = [["Masculino", "m"], ["Feminino", "f"]]

  attr_accessible :login, :email, :name, :password, :password_confirmation, :type, :provider, :uid, :state
  attr_accessor :old_password

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :confirmable,
         :validatable, :encryptable, :omniauthable,
         :encryptor => :restful_authentication_sha1,
         :omniauth_providers => [:facebook]

  before_save :default_values
  before_destroy :destroy_comments_by_user

  has_many :comments

  # Tanto pessoas físicas quanto jurídicas são usuários, e portanto têm login
  # e senha para criar propostas e editar seus perfis. Algumas pessoas físicas
  # - cidadãos, gestores pub. - podem pertencer a uma pessoa jurídica - empresa,
  # ONG, poder público -, e isso se dá na forma de uma árvore de usuários.
  #
  # Por exemplo:
  #
  # Empresa 1 -> Cidadão 3, Cidadão 5
  # ONG 2 -> Cidadão 6, Cidadão 7
  acts_as_tree

  # Contém nome, telefone, sexo, site, etc.
  has_one :dado, :class_name => "UserDado", :dependent => :delete
  delegate :nome, :descricao, :sexo, :idade, :site_url, :fone, :fax, :email_de_contato, :aniversario, {:to => :dado, :allow_nil => true}

  # Usuários possuem problemas e propostas
  has_many :topicos, :dependent => :destroy

  # Usuários aderem (se solidarizam) aos tópicos
  has_many :adesoes, :dependent => :destroy
  has_many :topicos_aderidos, :through => :adesoes, :source => :topico

  # Usuários seguem os tópicos
  has_many :seguidos, :dependent => :destroy

  # Guarda cada vez q o usuario fez login
  has_many :historico_de_logins, :dependent => :destroy, :class_name => 'HistoricoDeLogin'

  # Observatorios
  has_many :observatorios, :dependent => :destroy

  has_many :inspirations, :dependent => :destroy

  # O usuário pode incluir tags em tópicos.
  acts_as_tagger

  # O usuário tem uma imagem, seu avatar.
  has_many :imagens, :as => :responsavel, :dependent => :destroy
  def imagem
    imagem = self.imagens.first
    imagem ? imagem : nil
  end

  # O usuário tem uma localização: cidade, bairro, ponto no mapa...
  has_one :local, :as => :responsavel, :dependent => :destroy

  # oauth authorizations
  has_many :authorizations, :class_name => "UserAuthorization"


  validates_length_of :name,
                      :maximum => 100
  validates_presence_of :email
  validates_length_of :email,
                      :within => 6..100
  validates_uniqueness_of :email


  scope :do_tipo, lambda { |user_type|
    if user_type and not user_type.blank? and user_type != "usuarios"
      {
        :conditions => { :type => user_type.to_s.classify },
        :include => [ :local ]
      }
    end
  }

  scope :do_pais, lambda { |pais|
    if not pais.nil? and pais.kind_of?(Pais)
      {
        :conditions => [ "locais.pais_id = ?", pais.id ],
        :include => [ :local ]
      }
    end
  }

  scope :do_estado, lambda { |estado|
    unless estado.blank?
      if estado.kind_of?(Estado)
        estado_id = estado.id
      elsif estado.kind_of?(String)
        if (estado.size == "2") and (estado.to_i == 0) #eh uma abreviacao...
          estado_id = Estado.find_by_abrev(estado).id
        else
          estado_id = Estado.find(estado).id
        end
      else
        estado_id = estado
      end
      {
        :conditions => [ "locais.estado_id = ?", estado_id ],
        :include => [ :local ]
      }
    end
  }

  scope :da_cidade, lambda { |cidade|
    if cidade.kind_of?(Cidade)
      cidade_id = cidade.id
    elsif (cidade.to_i > 0)
      cidade_id = cidade.to_i
    else
      cidade_id = nil
    end
    if cidade_id and not cidade_id.blank?
      {
        :conditions => [ "locais.cidade_id = ?", cidade_id ],
        :include => [ :local ]
      }
    end
  }

  scope :do_bairro, lambda { |bairro|
    if not bairro.nil? and bairro.kind_of?(Bairro)
      {
        :conditions => [ "locais.bairro_id = ?", bairro.id ],
        :include => [ :local ]
      }
    end
  }

  scope :cadastrado_em, lambda { |dia|
    unless dia.nil?
      { :conditions => [ "DATE(users.created_at) = '#{dia.strftime('%Y-%m-%d')}' " ] }
    end
  }

  scope :nao_admin,
              :conditions => [ "users.type <> ?", "Admin" ]
  scope :nao_confirmados,
              :conditions => { :confirmed_at => nil }
  scope :ativos,
              :conditions => { :state => "active" }
  scope :aleatorios,
              :order => "rand()"
  scope :com_observatorio_ativo,
              :include => [ :observatorios ],
              :conditions => [ "observatorios.receber_email = ?", true ]

  def self.find_by_id_criptografado(crypted_id)
    begin
      User.find(User.decrypt(crypted_id))
    rescue ActiveRecord::RecordNotFound
      return false
    end
  end

  def self.find_by_auth(auth)
    authorization = UserAuthorization.find_by_provider_and_uid(auth.provider, auth.uid)
    authorization.user if authorization
  end

  def self.from_email(email)
    where(:email => email).first_or_initialize do |user|
      user.password = Devise.friendly_token[0,20]
    end
  end

  def add_auth_provider(auth)
    UserAuthorization.create :user => self, :provider => auth.provider, :uid => auth.uid
  end


  def default_values
    self.type ||= "Cidadao"
  end

  # Apaga os comentarios do usuario
  # antes de apaga-lo dos dados.
  def destroy_comments_by_user
    Comment.find_comments_by_user(self).each{ |c| c.destroy }
  end

  # Metodo abstrato:
  # i.e. os filhos implementam.
  def nome_do_tipo
  end

  # Metodo abstrato:
  def nome_da_classe
  end

  def admin?
    self.class == Admin
  end

  def pessoa?
    self.class == Cidadao or
    self.class == GestorPublico or
    self.class == Parlamentar
  end

  def organizacao?
    self.class == Organizacao or
    self.class == Empresa or
    self.class == Ong or
    self.class == PoderPublico or
    self.class == Universidade or
    self.class == Igreja or
    self.class == Conferencia
  end

  def poder_publico?
    self.class == PoderPublico
  end

  def id_criptografado
    return User.encrypt(self.id.to_s)
  end

  # User tem bairro?
  def tem_bairro?
    self.local and self.local.bairro
  end

  # User tem cidade?
  def tem_cidade?
    self.local and self.local.cidade
  end

  def self.update_counters(id, counters)
    super id, CalculateRelevance.for_counters(counters, COUNTERS_TO_RELEVANCE)
  end

  # Don't use this method on application flow. Only for rake tasks
  def reset_counters
    User.reset_counters(id, :topicos, :inspirations, :comments, :adesoes)
    self.relevancia = CalculateRelevance.for_counters(reload.attributes, COUNTERS_TO_RELEVANCE)["relevancia"]
    self.save(:validate => false)
  end

  def descricao_basica
  end

  def display_name
    self.nome
  end

  def owns?(model)
    self == model or (model.respond_to?(:user) and self == model.user)
  end

end
