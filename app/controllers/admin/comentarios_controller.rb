class Admin::ComentariosController < Admin::AdminController
  # GET /users
  # GET /users.xml
  def index
    @comments = Comment.paginate(:per_page => 20, :page => params[:page], :order => "id DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @comments }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @comment = Comment.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @comment = Comment.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @comment }
    end
  end

  # GET /users/1/edit
  def edit
    @comment = Comment.find(params[:id])
  end

#  # POST /users
#  # POST /users.xml
#  def create
#    @comment = User.new(params[:user])
#
#    respond_to do |format|
#      if @comment.save
#        flash[:notice] = "Usuário criado com sucesso."
#        format.html { redirect_to(admin_users_path) }
#        format.xml  { render :xml => @comment, :status => :created, :location => @comment }
#      else
#        format.html { render :action => "new" }
#        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
#      end
#    end
#  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @comment = Comment.find(params[:id])

    respond_to do |format|
      if @comment.update_attributes(params[:user])
        flash[:notice] = "Usuário atualizado com sucesso."
        format.html { redirect_to(admin_users_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @comment.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @comment = Comment.find(params[:id])
    @comment.destroy
    flash[:info] = "Comentario removido com sucesso."

    if params[:topico_id]
      topico = Topico.find(params[:topico_id])
      redirect_to topico_url(:topico_slug => topico.to_param)
    else
      redirect_to admin_comentarios_path
    end
  end

#  # Envia email do observatorio pro user.
#  def observatorio_email
#    @comment = User.find(params[:id])
#    UserMailer.observatorio(@comment).deliver
#    render :update do |page|
#      page.alert("Email enviado para #{@comment.email}!")
#    end
#  end
#
#  def mudartipo
#    @comment = User.find(params[:id])
#  end
#
#  def mudartipo_post
#    @comment = User.find(params[:id])
#    if @comment.update_attribute("type", params[:user][:type])
#      flash[:notice] = "Usuário atualizado com sucesso."
#      redirect_to(admin_users_path)
#    else
#      render :action => "mudartipo", :id => @comment.id
#    end
#  end


end
