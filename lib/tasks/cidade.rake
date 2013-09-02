# -*- encoding : utf-8 -*-
namespace :cidade do

  namespace :ajustes do
    desc "Lista os comentarios sem topico relacionado"
    task :orfaos => :environment do
      Comment.find(:all).each do |c|
        topico = Comment.find_commentable('Topico', c.commentable_id)
        if topico.nil?
          puts 'Este comentário não tem tópico: ' + c.id.to_s
        elsif topico.user.nil?
          puts 'Este comentário não tem usuário: ' + c.id.to_s
        end
      end
      Adesao.all.each do |a|
        if a.topico.nil?
          puts 'Esta adesão não tem tópico: ' + a.id.to_s
        end
        if a.user.nil?
          puts 'Esta adesão não tem usuário: ' + a.id.to_s
        end
      end
    end
  end

  namespace :avisos do
    desc "Envia e-mail semanal aos usuarios com Observatorio"
    task :observatorio => :environment do
      desde = 7.days.ago
      User.com_observatorio_ativo.all(:include => :dado).each do |user|
        if !user.observatorios.first.atividades(desde).empty? and user.active?
          puts "E-mail enviado para #{user.nome} (#{user.email})..."
          UserMailer.observatorio(user.id, desde).deliver
        end
      end
    end

    desc "Envia e-mail diário aos usuários não confirmados"
    task :nao_confirmados => :environment do
      dias = 7.days.ago
      User.cadastrado_em(dias).nao_confirmados.each do |user|
        puts "E-mail [para confirmar cadastro] enviado para #{user.email}"
        UserMailer.signup_last_try(user.id).deliver
      end
    end
  end

end
