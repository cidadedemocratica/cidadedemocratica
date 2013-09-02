class DefaultMetaTags
  attr_accessor :request

  def self.for(*args)
    self.new(*args).generate
  end

  def initialize(request, *args)
    self.request = request
  end

  def generate
    {
      :description => Settings.head_description,
      :keywords => Settings.head_keywords,
      :og => {
        :site_name => "Cidade Democrática",
        :type => "cause",
        :description => Settings.head_description,
        :url => request.protocol + request.host_with_port + request.fullpath,
        :image => "http://profile.ak.fbcdn.net/hprofile-ak-snc4/hs468.snc4/49311_100001089376554_6583_n.jpg"
      }
    }
  end
end
