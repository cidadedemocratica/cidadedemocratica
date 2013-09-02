module GraphHelper
  def self.counter
    @@counter ||= 0
  end

  def self.counter=(value)
    @@counter += value
  end

  def activities_graph(data)
    GraphHelper.counter += 1
    data = data.map do |date, value|
      [I18n.l(date.to_date, :format => :short), value]
    end

    "<div id='graph_contaniner#{GraphHelper.counter}' class='graph_contaniner'></div>
    <script>
      google.setOnLoadCallback(function () {
        var data = #{data.to_a.to_s}
        var options = { series: [{visibleInLegend: false}], chartArea: {left:'5%', top:'5%', width:'95%', height:'70%'} }

        data.unshift(['Data', 'Atividades'])
        data = google.visualization.arrayToDataTable(data)

        new google.visualization.LineChart(document.getElementById('graph_contaniner#{GraphHelper.counter}')).draw(data, options)
      })
    </script>".html_safe
  end

  def pie_graph(data)
    GraphHelper.counter += 1
    "<div id='graph_contaniner#{GraphHelper.counter}' class='graph_contaniner'></div>
    <script>
      google.setOnLoadCallback(function () {
        var data = #{data.to_a.to_s}
        var options = { chartArea: {left:'0', top:'6%', width:'100%', height:'88%'} }

        data.unshift(['Data', 'Atividades'])
        data = google.visualization.arrayToDataTable(data)

        new google.visualization.PieChart(document.getElementById('graph_contaniner#{GraphHelper.counter}')).draw(data, options)
      })
    </script>".html_safe
  end
end
