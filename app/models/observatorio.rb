class Observatorio < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :tags,
                          :join_table => "observatorios_tem_tags",
                          :table_name => "observatorios_tem_tags"

  has_many :locais, :as => :responsavel, :dependent => :destroy

  validates_presence_of :nome
  validates_associated :locais

  attr_accessible :tag_ids, :receber_email

  # Dada uma tag (name!), mostrar quais observatorios usam-na.
  scope :com_tag, lambda { |tag_name|
    if tag_name.blank?
      {}
    else
      {
        :joins => "INNER JOIN observatorios_tem_tags INNER JOIN tags ON (observatorios_tem_tags.observatorio_id = observatorios.id) AND (observatorios_tem_tags.tag_id = tags.id)",
        :conditions => [ "tags.name = ?", tag_name ]
      }
    end
  }

  # Descreve automaticamente o observatorio
  # criado: Ex.: PP dos temas x, y, z em A e B e C.
  def auto_descricao
    str = "Propostas e problemas "
    # TAGS...
    if not self.tags.empty?
      str += (self.tags.size > 1) ? "dos temas " : "do tema "
      str += "<span class=\"tags\">"
      str += self.tags.collect{ |t| t.name }.join(", ")
      str += "</span>"
    end
    # LOCAIS...
    if not self.locais.empty?
      tmp = []
      for local in self.locais
        aux  = " em <b>#{local.cidade.nome}</b> (#{local.cidade.estado.abrev})"
        aux += ", no bairro <i>#{local.bairro.nome}</i>" if local.bairro
        tmp << aux
      end
      str += tmp.join(" e ")
    end
    return str
  end

  # Retorna os IDs dos topicos
  # filtrados pelo observatorio
  def topico_ids
    Topico.com_tags(self.tag_ids).nos_locais(self.locais).all(:select => "topicos.id")
  end

  # Retorna Array com atividades (Apoios + Comentarios) 
  # de todos os topicos filtrados pelo observatorio.
  # Se informado "depois_de", apenas depois dessa data;
  # Se não, TODAS!
  def atividades(depois_de = nil)
    atividades = []

    topicos = Topico.com_tags(self.tag_ids).nos_locais(self.locais).apos_o_dia(depois_de).all(:order => "topicos.id DESC")
    atividades += topicos

    topico_ids = Topico.com_tags(self.tag_ids).nos_locais(self.locais).all(:order => "topicos.id DESC").collect{ |t| t.id }
    if topico_ids and !topico_ids.empty?
      # Comentarios feitos
      depois_de_sql = depois_de.nil? ? "" : " AND created_at >= '#{depois_de}'"
      Comment.find(:all,
                   :conditions => ["commentable_type = 'Topico' AND 
                                    commentable_id IN (?) #{depois_de_sql}", topico_ids],
                   :order => "created_at DESC").each { |c| atividades << c }

      # Apoios/Adesoes
      Adesao.dos_topicos(topico_ids).depois_de(depois_de).all.each { |a| atividades << a }
    end

    return atividades.sort!{ |x, y| x.created_at <=> y.created_at }.reverse!
  end
end
