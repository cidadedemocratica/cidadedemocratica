class CommentsController < ApplicationController
  before_filter :authenticate_user!, :only => [ :create ]
  before_filter :verificar_se_pode_editar, :only => [ :set_comentario_body ]

  # Permite a edição do comentário na lista de topicos
  in_place_edit_for :comentario, :body

  # Metodos que não precisam de authenticity token
  protect_from_forgery :except => [ :processar, :create, :set_comentario_body ]

  def processar
    @comment = Comment.new(params[:comment])
    @comment.commentable_id = params[:topico_id]
    @comment.commentable_type = "Topico"
    session[:novo_comentario] = @comment
    redirect_to create_comment_path
  end

  def create
    @comment = session[:novo_comentario]
    @topico = Topico.find(@comment.commentable_id)

    @comment.user = current_user
    # @topico.comment_threads << @comment
    if @comment.save
      session[:novo_comentario] = nil

      NewCommentPostman.new(@topico, @comment).deliver

      flash[:notice] = "Comentário criado com sucesso."
      redirect_to topico_path(@topico)
    else
      render topicos_path
    end
  end

  def body
    comentario = Comment.find(params[:id])
    render :text => comentario.body
  end

  private

  def verificar_se_pode_editar
    @comentario = Comment.find(params[:id])
    if user_signed_in? and not current_user.admin?
      if current_user != @comentario.user
        flash[:warning] = "Você não tem permissão para editar esse comentário."
        redirect_to topico_url(:topico_slug => @topico.to_param) and return false
      end
    end
  end

end
