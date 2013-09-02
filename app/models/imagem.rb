class Imagem < ActiveRecord::Base
  belongs_to :responsavel, :polymorphic => true
  attr_accessible :uploaded_data, :legenda

  # Taken from: http://svn.techno-weenie.net/projects/plugins/attachment_fu/README
  has_attachment(
    :content_type => :image,
    :max_size => 2.megabytes,
    :resize_to => "640x480>",
    :thumbnails => { :thumb => '75x75',
                     :small => '50x50',
                     :mini  => '30x30',
                     :preresize => '640x480>'},
    :storage => :file_system,
    :path_prefix => 'public/images/uploaded'
  )

  validates_as_attachment

  acts_as_list :scope => :responsavel

  after_create :process_preresize

  # taken from: http://groups.google.com/group/javascript-image-cropper-ui/browse_thread/thread/99dd2c186006539d
  # this is a destructive operation and the original image will be replaced by the cropped version
  def crop_original(width, height, x1, y1, input_kind = :preresize, output = full_path)
    geometry = "#{width.to_i}x#{height.to_i}+#{x1.to_i}+#{y1.to_i}"
    image = MiniMagick::Image.open(full_path(input_kind))
    image.combine_options do |c|
      c.crop(geometry)
      c.repage.+
    end
    image.write(output)
  end

  def create_resized_versions(final = "200x200")
    resize(:size => "30x30", :kind => :mini)
    resize(:size => "50x50", :kind => :small)
    resize(:size => "75x75", :kind => :thumb)
    resize(:size => final, :output => full_path)
  end

  alias_method :dup!, :dup
  def dup
    model = self.dup!

    img = self.create_temp_file rescue nil
    if img
      model.temp_paths.unshift img
      model.save_to_storage

      model.save

      model.resize(:size => "30x30", :kind => :mini)
      model.resize(:size => "50x50", :kind => :small)
      model.resize(:size => "75x75", :kind => :thumb)
      model.resize(:size => "640x", :output => model.full_path)
    end

    model
  end

  protected

  def full_path(kind = nil)
    "#{Rails.root.to_s}/public#{public_filename(kind)}"
  end

  def resize(options = {})
    image = MiniMagick::Image.open(full_path) rescue return
    image.resize(options[:size])
    image.write(options[:output] || full_path(options[:kind]))
  end

  def process_preresize
    after_process_attachment
    resize(:size => "640x", :kind => :preresize)
    create_resized_versions("640x")
  end
end
