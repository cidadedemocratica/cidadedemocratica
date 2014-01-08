xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0"){
  xml.channel do
    xml.title "#{@user.nome} no Cidade Democratica"
    xml.link link_to perfil_url(@user)
    xml.description "Feed das atividades no Cidade Democratica."
    xml.language 'pt-br'
    @atividades.each do |feed_item|
      next if feed_item == nil
      render :partial => "feed_item/#{feed_item.class.name.underscore}", :locals => {:feed_item => feed_item, :xml_instance => xml}
    end
  end
}
