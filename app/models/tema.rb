class Tema < Tag
  # Dada uma tag, retornar todos os users que jah utilizaram-na
  def users
    u = []
    Topico.tagged_with(self).each{ |t| u << t.user }
    return u
  end
end
