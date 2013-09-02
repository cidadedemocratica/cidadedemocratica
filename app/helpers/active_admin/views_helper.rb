module ActiveAdmin::ViewsHelper
  include GraphHelper

  def words_cloud(data, classes = %w(cloud_1 cloud_2 cloud_3 cloud_4 cloud_5))
    max_count = data.values.max
    data.each do |word, count|
      index = (count.to_f / max_count * (classes.size - 1)).to_i
      yield word, count, classes[index]
    end
  end
end
