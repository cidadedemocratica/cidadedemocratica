module TitleHelper
  #
  # = Title Helper
  #
  # Copied from helperful
  #
  # This helper provides both input and output capabilities
  # for managing page title in Rails views and layouts.
  #
  # When called with +args+, it stores all args for later retrieval.
  # Additionally, it always return a formatted title so that
  # it can be easily called without arguments to display the full page title.
  #
  # You can pass some additional options to customize the behavior of the returned string.
  # The following options are supported:
  #
  # :separator::
  #   the separator used to join all title elements, by default a dash.
  #
  # :site::
  #   the name of the site to be appended to page title.
  #
  # :headline::
  #   website headline to be appended to page title, after any element.
  #
  # ==== Examples
  #
  #   # in a template set the title of the page
  #   <h1><%= title "Latest news" %></h1>
  #   # => <h1>Latest news</h1>
  #
  #   # in the layout print the title of the page
  #   # with the name of the site
  #   <title><%= title :site => 'My Site' %></title>
  #   # => <title>Latest news | My Site</title>
  #
  def title(*args)
    @helperful_title ||= []
    @helperful_title_options ||= {
      :separator => ' - ',
      :headline  => nil,
      :site      => nil,
    }
    options = args.extract_options!

    @helperful_title += args
    @helperful_title_options.merge!(options)

    t =  @helperful_title.clone
    t << @helperful_title_options[:site]
    t << @helperful_title_options[:headline]
    t.compact.join(@helperful_title_options[:separator])
  end

end
