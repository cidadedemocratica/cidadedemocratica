ActiveAdmin.register_page "Relatórios" do
  controller do
    private

    def report_base
      locals     = GeneralReportLocals.new(@report.local_scoped)
      users      = GeneralReportUsers.new
      topics     = GeneralReportTopics.new
      activities = GeneralReportActivities.new(@report.from, @report.to)
      words      = GeneralReportWords.new

      @report.collections.each do |name, collection|
        collection.each do |model|
          activities.add(name, model)
          locals.add(name, model)
          users.add(name, model)
          topics.add(name, model)
        end
      end

      topics.relevance!
      users.relevance!

      words.add_collection(@report.topics, [:descricao, :titulo])
      words.add_collection(@report.comments, :body)

      ## Variables
      @activities       = activities.data
      @activities_stats = activities.stats
      @locals           = locals.data
      @words_counted    = words.count
      @topics           = topics.data
      @users            = users.data
      @users_by_group   = users.data_by_group

      render :base
    end

    def report_tags_matrix
      csv = AssociativeMatrix.new(*@report.tags_grouped_by_topics).to_csv
      send_data csv, :filename => "report_tags_matrix.csv"
    end

    def report_locals_matrix
      csv = AssociativeMatrix.new(*@report.locals_grouped_by_topics).to_csv
      send_data csv, :filename => "report_locals_matrix.csv"
    end

    def report_users_matrix
      topics = GeneralReportTopics.new
      @report.collections.each do |name, collection|
        collection.each do |model|
          topics.add(name, model)
        end
      end
      csv = AssociativeMatrix.new(*topics.users_grouped).to_csv
      send_data csv, :filename => "report_users_matrix.csv"
    end
  end

  page_action :generate, :method => :post do
    @report = GeneralReport.new(params[:general_report])
    send "report_#{@report.type}"
  end

  page_action :tags do
    @report = GeneralReport.new(params[:general_report])
    render :json => @report.allowed_tags.order(:name).map(&:name)
  end

  content :title => "Gerar Relatório"  do
    render :partial => 'form', :locals => {
      :competitions => Competition.all,
      :tags => [],
      :macro_tags => Hash[MacroTag.includes(:tags).all.map { |macro_tag| [macro_tag.title, macro_tag.tags.map(&:name).join(",")] }],
      :report => GeneralReport.new
    }
  end
end
