unless %w(production staging).include? Rails.env
  namespace :spec do
    desc 'Runs non browser tests'
    RSpec::Core::RakeTask.new(:travis) do |t|
      t.pattern = Dir["spec/**/*_spec.rb"].reject { |f| f['/features'] }
    end
  end
end
