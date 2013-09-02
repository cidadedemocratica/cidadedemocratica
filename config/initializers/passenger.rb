if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    if forked
      Rails.cache.instance_variable_get(:@data).reset if Rails.cache.class == ActiveSupport::Cache::MemCacheStore
    end
  end
end
