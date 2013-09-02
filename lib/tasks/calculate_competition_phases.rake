# -*- encoding : utf-8 -*-
namespace :cd do
  desc 'Atualiza fases das competições'
  task :update_phases => :environment do
    Competition.all.each do |competition|
      old_phase = competition.current_phase
      new_phase = competition.calculate_current_phase
      if old_phase != new_phase
        puts "Updating competition with id #{competition.id} from #{old_phase} to #{new_phase}"
        competition.save
      end
    end
  end
end
