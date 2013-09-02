class Admin::TagsController < Admin::AdminController
  in_place_edit_for :tag, :name
  skip_before_filter :verify_authenticity_token,
                     :only => :set_tag_name

  # GET /tags
  # GET /tags.xml
  def index
    conditions = []
    if params[:init] and not params[:init].blank?
      conditions = ["name LIKE ?", params[:init]+'%']
    end
    @tags = Tag.paginate(:conditions => conditions,
                         :per_page => 100,
                         :page => params[:page])
    @letras = Tag.find_by_sql('SELECT LEFT(tags.name, 1) AS letra, COUNT(*) AS total FROM tags GROUP BY LEFT(tags.name, 1);')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tags }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    @tag = Tag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tag/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.xml
  def create
    @tag = Tag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        flash[:notice] = "Tag criada com sucesso."
        format.html { redirect_to(admin_tags_path) }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = "Tag atualizada com sucesso."
        format.html { redirect_to(admin_tags_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag = Tag.find(params[:id])
    # Remover as relações dos observatorios
    Observatorio.com_tag(@tag.name).each do |o|
      o.tags.delete(@tag)
    end
    @tag.destroy
    render :update do |page|
      page.remove "row_#{params[:id]}"
    end
    # Old way...
    #respond_to do |format|
    #  format.html { redirect_to(admin_tags_path) }
    #  format.xml  { head :ok }
    #end
  end

  def maistags
  end

  def novastags
    tags = []
    params[:nomes_das_tags].strip.split("\n").each do |b|
      tags << Tag.create(:name => b.strip)
    end
    flash[:notice] = "#{tags.size} tags criadas com sucesso!"
    redirect_to :action => "index"
  end

  def transferencia
  end

  def transferencia_post
    #render :text => params
    if request.post?
      tag_de   = Tag.find_by_name(params[:tag][:de])
      tag_para = Tag.find_by_name(params[:tag][:para])
      if tag_de and tag_para
        transfere(tag_de, tag_para)
        flash[:notice] = "Tag #{params[:tag][:de]} transferida para #{tag_para.name}"
        redirect_to :action => "index"
      else
        flash[:notice] = "Não encontramos tags com os nomes #{params[:tag][:de]} e #{params[:tag][:para]}"
        redirect_to :action => "transferencia"
      end
    end
  end

  def transfere_drag
    tag_de = ActsAsTaggableOn::Tag.find(params[:id])
    @tag   = ActsAsTaggableOn::Tag.find(params[:tag_para])
    if tag_de and @tag
      transfere(tag_de, @tag)
      render :update do |page|
        page.alert("Tag transferida com sucesso para '#{@tag.name}'.")
        page.remove "row_#{params[:id]}"
        page.replace "row_#{@tag.id}",
                      :partial => "tag_row",
                      :locals => {
                        :tag => @tag
                      }
        page.visual_effect :highlight, "row_#{@tag.id}"
      end
    end
  end

  def separar
    tag_de = Tag.find(params[:id])
    i = 0
    params[:name].split(',').each do |nova_tag|
      tag_para = Tag.find_or_create_by_name(nova_tag.strip)
      transfere_relacoes(tag_de, tag_para)
      transfere_observatorios(tag_de, tag_para)
      i += 1
    end
    # Destruir a tag
    tag_de.destroy
    render :update do |page|
      page.alert("Antiga tag removida: #{i} tags criadas/reutilizadas.")
      page.remove "row_#{params[:id]}"
    end
  end

  protect_from_forgery

  private

  def transfere(tag_de, tag_para)
    transfere_relacoes(tag_de, tag_para)
    transfere_observatorios(tag_de, tag_para)
    # Destruir a tag para evitar sugeri-la futuramente noutros livesearch de users...
    tag_de.destroy
    tag_para.reload
  end

  def transfere_relacoes(tag_de, tag_para)
    # Transferir as relacoes...
    tag_de.taggings.each do |t|
      t.tag_id = tag_para.id
      t.save
    end
  end

  def transfere_observatorios(tag_de, tag_para)
    # Transferir os observatorios
    Observatorio.com_tag(tag_de.name).each do |o|
      o.tags.delete(Tag.find(tag_de.id))
      o.tags << Tag.find(tag_para.id) unless o.tag_ids.include?(tag_para.id)
    end
  end
end
