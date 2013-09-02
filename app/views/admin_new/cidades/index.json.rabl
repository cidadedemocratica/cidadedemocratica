collection @cidades
attributes :id, :nome
node :full_name do |city|
  "#{city.nome} - #{city.estado.abrev}"
end
