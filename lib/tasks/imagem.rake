# -*- encoding : utf-8 -*-
desc "Find missing thumbnails and process them"
task :reprocess_thumbs => :environment do
  Imagem.where(:thumbnail => nil).order("id desc").find_each do |imagem|
    full_path = File.join(Rails.root, "public", imagem.public_filename(:small))
    unless File.exists?(full_path)
      begin
        imagem.create_resized_versions
        print "."
      rescue
        print "#"
      end
    end
  end
end
