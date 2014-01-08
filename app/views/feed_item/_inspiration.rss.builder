xml = xml_instance unless xml_instance.nil?
xml.item do
  p = feed_item
  xml.title "Inspiração #{p.title}"
  xml.description p.description
  xml.author "#{p.user.name} (#{p.user.email})"
  xml.pubDate p.updated_at
  xml.link competition_inspiration_url(:competition_id => p.competition_id, :id => p.to_param)
  xml.guid perfil_url(:id => p.user.id)
end

