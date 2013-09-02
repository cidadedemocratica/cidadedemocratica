class Contato
  include Validateable
  attr_accessor :nome,
                :email,
                :mensagem

  validates_presence_of :nome
  validates_presence_of :email
  validates_presence_of :mensagem
  validates_format_of :email,
                      :with => /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/

  def enviar(usuario_destinatario)
    UserMailer.contato(usuario_destinatario.id, {
      "nome" => self.nome,
      "email" => self.email,
      "mensagem" => self.mensagem}).deliver
  end
end
