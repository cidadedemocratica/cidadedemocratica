class Admin::MacroTagsController < Admin::AdminController
  inherit_resources

  actions :all, :except => [:show]

  protected
  def collection
    @macro_tags ||= end_of_association_chain.paginate(:page => params[:page])
  end
end
