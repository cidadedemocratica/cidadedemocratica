
if defined?(WillPaginate)

  WillPaginate::ViewHelpers.pagination_options[:inner_window] = 2 # links around the current page
  WillPaginate::ViewHelpers.pagination_options[:outer_window] = 0 # links around beginning and end

  # hack to work with kaminari and activeadmin
  module WillPaginate
    module ActiveRecord
      module RelationMethods
        def per(value = nil) per_page(value) end
        def total_count() count end
      end
    end
    module CollectionMethods
      alias_method :num_pages, :total_pages
    end
  end
end
