class AvatarController < ApplicationController
  before_filter :authenticate_user!

  def new
    @user = current_user
    @imagem = Imagem.new
  end

  def create
    @user = current_user
    if @user.imagem
      imagem = @user.imagem
      imagem.destroy
    end
    @user.reload
    if @user.imagens.create(params[:imagem])
      flash[:notice] = "Imagem salva com sucesso."
      session[:can_resize] = 1
      redirect_to :action => "resize"
    end
  end

  def resize
    @user = current_user
    if @user.imagem # and TODO: image_size > 190x190...
      if request.post? and params[:x1] and params[:y1] and params[:width] and params[:height]
        @user.imagem.crop_original(params[:width], params[:height], params[:x1], params[:y1])
        @user.imagem.create_resized_versions
        session[:can_resize] = nil
        redirect_to perfil_path(@user)
      end
    else
      redirect_to perfil_path(@user)
    end
  end

  def destroy
    @user = current_user
    @imagem = @user.imagem
    if @imagem
      @imagem.destroy
      flash[:notice] = "Imagem removida com sucesso."
      redirect_to perfil_path(@user)
    end
  end

end
