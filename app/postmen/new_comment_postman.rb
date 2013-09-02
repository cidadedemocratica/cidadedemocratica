class NewCommentPostman
  attr_accessor :topico, :comment

  def initialize(topico, comment)
    self.topico = topico
    self.comment = comment
  end

  def deliver
    TopicoMailer.new_comment(topico.user.id, topico.id, comment.id).deliver if topico.user.active?

    topico.usuarios_que_seguem.each do |u|
      TopicoMailer.new_comment(u.id, topico.id, comment.id).deliver if u.active?
    end
  end
end
