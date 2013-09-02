xml = xml_instance unless xml_instance.nil?
xml.item do
  p = feed_item
  xml.title "Criou #{p.nome_do_tipo(:artigo => :definido)} #{p.titulo.capitalize}"
  xml.description p.descricao
  xml.author "#{p.user.name} (#{p.user.email})"
  xml.pubDate p.updated_at
  xml.link topico_url(:topico_slug => p.to_param)
  xml.guid perfil_url(:id => p.user.id)
end