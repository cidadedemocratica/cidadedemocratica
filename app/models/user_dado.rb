class UserDado < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :nome

  attr_accessible :nome, :sexo, :aniversario, :fone, :fax, :email_de_contato, :site_url, :descricao

  # Valida dados mínimos da pessoa
  with_options :if => :pessoa? do |pessoa|
    pessoa.validates_presence_of :sexo
    pessoa.validates_presence_of :aniversario
  end

  # Valida dados mínimos do admin
  with_options :if => :admin? do |admin|
    admin.validates_presence_of :sexo
    admin.validates_presence_of :aniversario
  end
  
  # Valida dados mínimos de organizacao
  with_options :if => :organizacao? do |organizacao|
    organizacao.validates_presence_of :fone
  end  

  # How old is he/she? Has his/her birthday occured this year yet?
  # Subtract 1 if so, 0 if not
  def idade
    if self and self.aniversario
      hoje = Time.now
      return hoje.year - self.aniversario.year - (self.aniversario.to_time.change(:year => hoje.year) > hoje ? 1 : 0)
    end
  end

  protected
  
  def pessoa?
    self.user.pessoa?
  end
  
  def admin?
    self.user.admin?
  end
  
  def organizacao?
    self.user.organizacao?
  end

end
