xml = xml_instance unless xml_instance.nil?
xml.item do
	c = feed_item
	topico = Topico.find(c.commentable_id)

	case c.tipo
	when 'comentario'
		xml.title "Comentou em #{topico.titulo}"
		xml.description c.body
		xml.author "#{c.user.nome} (#{c.user.email})"
		xml.pubDate c.updated_at
		xml.link topico_url(:topico_slug => topico.to_param)
		xml.guid perfil_url(c.user)
	when 'pergunta'
		xml.title "Perguntou em #{topico.titulo}"
		xml.description c.body
		xml.author "#{c.user.nome} (#{c.user.email})"
		xml.pubDate c.updated_at
		xml.link topico_url(:topico_slug => topico.to_param)
		xml.guid perfil_url(c.user)	
	when 'resposta'
		xml.title "Respondeu em #{topico.titulo}"
		xml.description c.body
		xml.author "#{c.user.nome} (#{c.user.email})"
		xml.pubDate c.updated_at
		xml.link topico_url(:topico_slug => topico.to_param)
		xml.guid perfil_url(c.user)
	when 'ideia'
		xml.title "Deu uma ideia em #{topico.titulo}"
		xml.description c.body
		xml.author "#{c.user.nome} (#{c.user.email})"
		xml.pubDate c.updated_at
		xml.link topico_url(:topico_slug => topico.to_param)
		xml.guid perfil_url(c.user)
	end

end