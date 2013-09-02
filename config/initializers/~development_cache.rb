if Rails.env.development?

  models = []
  
  Dir.chdir("#{Rails.root}/app/models") do
    Dir["**/*"].reject{|o| File.directory? o}.each do |model|
      model.sub!(/\..*$/, "")

      require_dependency model
      models << model
    end 
  end

  puts "Prevent development cache error [initializer/development_cache.rb]"
  puts " Required models: #{models.join ", "}"

end
