ActiveAdmin.register Tag do
  menu :parent => "Tópicos", :priority => 3

  index do
    selectable_column

    column :id
    column :name
    column :count do |tag|
      tag.taggings.count
    end
    column :join do |tag|
      link_to(I18n.t('active_admin.join_tags_to_that'), join_tags_admin_new_tag_path(tag))
    end
    default_actions
  end

  member_action :join_tags do
    @tag = resource
  end

  member_action :join_tags_update, :method => :post do
    @tag = resource
    tags = params[:join_tags][:tags] || []
    tags = tags.reject(&:blank?).map(&:to_i).select { |t| t != @tag.id }
    if tags.size > 0
      Tag.join_tags(@tag.id, tags)
      flash[:notice] = "Tags unidas com sucesso"
    else
      flash[:error] = "Você deve escolher pelo menos uma tag para unir"
    end
    redirect_to :action => :index
  end

  filter :name
end
