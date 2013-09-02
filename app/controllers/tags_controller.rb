class TagsController < ApplicationController

  def auto_complete_responder
    tags = Tag.find(:all,
                    :conditions => [ 'name LIKE ?', '%' + params[:tag] + '%'],
                    :order => 'name ASC',
                    :limit => 8)
    if tags
      render :partial => 'auto_complete_responder',
             :locals => {
               :tags => tags,
               :typed => params[:tag]
             }
    else
      render :nothing => true
    end
  end

end
