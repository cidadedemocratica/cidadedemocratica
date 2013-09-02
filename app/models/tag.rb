class Tag < ActsAsTaggableOn::Tag
  attr_accessible :name

  # LIKE is used for cross-database case-insensitivity
  def self.find_or_create_with_like_by_name(name)
    find(:first, :conditions => ["name LIKE ?", name]) || create(:name => name)
  end

  def ==(object)
    super || (object.is_a?(Tag) && name == object.name)
  end

  def to_s
    name
  end

  def count
    read_attribute(:count).to_i
  end

  def slug
    self.name.remove_acentos
  end

  # Dada uma tag, retornar tags relacionadas,
  # por meio dos tópicos que possuem a mesma tag.
  def self.relacionadas(tag, options = {})
    Rails.cache.fetch(Digest::SHA1.hexdigest("Tag.relacionadas-#{tag}-#{options.to_param}"), :expires_in => 5.minutes ) do
      if tag
        condicoes = []
        condicoes << "1 = 1"
        condicoes << "topicos.type = '#{options[:topico_type].to_s.singularize.camelize}'" if options[:topico_type] and (options[:topico_type]!="topicos")
        condicoes << "users.type = '#{options[:user_type].to_s.singularize.camelize}'" if options[:user_type] and (options[:user_type]!="usuarios")
        condicoes << "locais.pais_id = '#{options[:pais].id}'" if options[:pais]
        condicoes << "locais.estado_id = '#{options[:estado].id}'" if options[:estado]
        condicoes << "locais.cidade_id = '#{options[:cidade].id}'" if options[:cidade]
        condicoes << "locais.bairro_id = '#{options[:bairro].id}'" if options[:bairro]

        plus_localizacao = (condicoes.size > 1) ? " AND taggable_id IN (
SELECT topicos.id
FROM topicos
   JOIN locais
   JOIN users
   ON (topicos.id = locais.responsavel_id) AND
      (locais.responsavel_type = 'Topico') AND
      (topicos.user_id = users.id)
WHERE #{condicoes.join(' AND ')}
    )" : " "

      sql_string = <<MYSTRING.gsub(/\s+/, " ").strip
      SELECT tags.id, tags.name, z.total
      FROM tags INNER JOIN (
        SELECT p.tag_id, count(p.tag_id) AS total
        FROM taggings p
           WHERE p.taggable_type = 'Topico'
           AND p.context = 'tags'
           AND p.tag_id = #{tag.id}
               #{plus_localizacao}
        GROUP BY p.tag_id
      ) z ON tags.id = z.tag_id
      WHERE tags.id <> #{tag.id}
      ORDER BY z.total DESC
MYSTRING
        Tag.find_by_sql(sql_string)
      else
        []
      end
    end
  end

  # Dado um contexto (pais, estado, cidade, bairro etc.),
  # retornar as TAGS (e os counts) dessas variaveis.
  def self.do_contexto(options = {})
    Rails.cache.fetch(Digest::SHA1.hexdigest("Tag.do_contexto-#{options.to_param}"), :expires_in => 5.minutes ) do
      # Strings a parte...
      condicoes = []
      condicoes << "1 = 1"
      condicoes << "topicos.id IN (#{options[:topico_ids].join(", ")})" if options[:topico_ids]
      condicoes << "topicos.type = '#{options[:topico_type].to_s.singularize.camelize}'" if options[:topico_type] and (options[:topico_type]!="topicos")
      condicoes << "users.type = '#{options[:user_type].to_s.singularize.camelize}'" if options[:user_type] and (options[:user_type]!="usuarios")
      condicoes << "locais.pais_id = '#{options[:pais].id}'" if options[:pais]
      condicoes << "locais.estado_id = '#{options[:estado].id}'" if options[:estado]
      condicoes << "locais.cidade_id = '#{options[:cidade].id}'" if options[:cidade]
      condicoes << "locais.bairro_id = '#{options[:bairro].id}'" if options[:bairro]

      #sql_string_tag   = options[:tag] ? " AND tag_id = #{options[:tag].id} " : ""
      sql_string_tag   = ""
      sql_string_order = options[:order].nil?  ? "z.total DESC" : options[:order]
      sql_string_limit = options[:limit].nil?  ? "" : " LIMIT #{options[:limit]}"

      sql_string = <<MYSTRING.gsub(/\s+/, " ").strip
      SELECT tags.*, z.total
      FROM tags JOIN (
        SELECT p.tag_id, count(p.tag_id) AS total
          FROM topicos
          JOIN users ON (topicos.user_id = users.id)
          JOIN locais ON (locais.responsavel_id = topicos.id)
             AND (locais.responsavel_type = 'Topico')
          JOIN taggings p ON (topicos.id = p.taggable_id)
             AND p.taggable_type = 'Topico'
             AND p.context = 'tags'
             #{sql_string_tag}
          WHERE #{condicoes.join(" AND ")}
          GROUP BY p.tag_id
      ) z
      ON (z.tag_id = tags.id)
      ORDER BY #{sql_string_order}
      #{sql_string_limit}
MYSTRING

      Tag.find_by_sql(sql_string)
    end
  end

  # Retorna as tags mais comuns do usuário.
  def self.do_usuario(user_id, options = {})
    Rails.cache.fetch(Digest::SHA1.hexdigest("Tag.do_usuario-#{user_id}-#{options.to_param}"), :expires_in => 5.minutes ) do
      condicoes = []
      condicoes << "topicos.user_id = #{user_id}"
      condicoes << "topicos.type = '#{options[:topico_type].to_s.singularize.camelize}'" if options[:topico_type] and (options[:topico_type]!="topicos")

      sql_string_order = options[:order].nil?        ? "z.total DESC" : options[:order]
      sql_string_limit = options[:limit].nil?        ? "" : " LIMIT #{options[:limit]}"

      sql_string = <<MYSTRING.gsub(/\s+/, " ").strip
        SELECT tags.id, tags.name, tags.relevancia, z.total
        FROM tags JOIN (
          SELECT p.tag_id, count(p.tag_id) AS total
            FROM topicos
            JOIN taggings p ON (topicos.id = p.taggable_id)
               AND p.taggable_type = 'Topico'
               AND p.context = 'tags'
            WHERE #{condicoes.join(" AND ")}
            GROUP BY p.tag_id
        ) z
        ON (z.tag_id = tags.id)
        ORDER BY #{sql_string_order}
        #{sql_string_limit}
MYSTRING
      Tag.find_by_sql(sql_string)
    end
  end

  def self.join_tags(to_tag_id, from_tag_id)
    ActsAsTaggableOn::Tagging.update_all({ :tag_id => to_tag_id }, { :tag_id => from_tag_id })
    ActsAsTaggableOn::Tag.delete_all(:id => from_tag_id)
    Tag.remove_duplicate(to_tag_id)
  end

  def self.remove_duplicate(tag_id)
    tagging = ActsAsTaggableOn::Tagging.where(:tag_id => tag_id)
    uniq_ids = tagging.uniq_by { |t| [t.taggable_id, t.taggable_type] }.map(&:id)
    if uniq_ids.size > 0
      tagging.where("id NOT IN(?)", uniq_ids).delete_all
    end
  end

end
