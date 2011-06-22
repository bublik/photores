# == Schema Information
#
# Table name: photos
#
#  id               :integer         not null, primary key
#  title            :string(255)
#  user_id          :integer
#  parent_id        :integer
#  size             :integer
#  content_type     :string(255)
#  filename         :string(255)
#  height           :integer
#  width            :integer
#  thumbnail        :string(255)
#  registred        :boolean
#  auto_approve     :boolean         default(TRUE)
#  views            :integer         default(0)
#  complaint        :integer         default(0)
#  downloads        :integer         default(0)
#  comments_count   :integer         default(0)
#  comment_at       :date
#  show_at          :date
#  download_at      :date
#  created_at       :datetime
#  updated_at       :datetime
#  photo_profile_id :integer
#  contest_id       :integer
#  is_moderated     :boolean         default(TRUE)
#  exif             :text
#  want_critic      :boolean         default(TRUE)
#  lat              :decimal(15, 10)
#  lng              :decimal(15, 10)
#

require 'colormap'
class Photo < ActiveRecord::Base
  # include HTML
  #для четния exif информации
  #gem install exifr || mini_exiftool
  belongs_to :user, :counter_cache => true
  belongs_to :photo_profile
  has_and_belongs_to_many :photo_categories
  has_and_belongs_to_many :photo_albums
  belongs_to :contest
  has_many :histograms, :dependent => :destroy
  has_many :photo_notes
 
  acts_as_taggable
  acts_as_commentable
  acts_as_rated(:rating_range => 1..10)
  #Describe for use  http://github.com/andre/geokit-rails
  acts_as_mappable :default_units => :kms,
    :default_formula => :sphere,
    :distance_field_name => :distance,
    :lat_column_name => :lat,
    :lng_column_name => :lng

  serialize :exif
  attr_accessor_with_default :exif_attr, {
    1 => :make,
    2 => :model,
    3 => :software,
    4 => :pixel_x_dimension,
    5 => :pixel_y_dimension,
    6 => :flash,
    7 => :focal_length,
    8 => :focal_length_in_35mm_film,
    9 =>  :iso_speed_ratings,
    10 => :date_time_original,
    # 11 => :user_comment
  }

  NUM_COLORS = 9
  @@per_page = 10
  @@total_entries = 15
  @@row_out_entries = 4

  @@states = {:added => 'Добавил новую фотографию.',
    :delete => 'Фотография была удалена.',
    :complaint => 'На вашу работу поступила жалоба.',
    :changed => 'Изменил описание к фотографии.',
    :vote => 'Получил(а) оценку за фотографию.',
  }

  cattr_reader :per_page, :states
  attr_accessor :current_state 

  has_attachment :content_type => :image,
    :storage => :file_system,
    :size => APP_CONFIG['min_photo_size'].to_i.kilobytes..6.megabytes,
    :thumbnails => {:medium => '800x600>', :thumb => '360x260>', :crop => '50x50!'}, #:thumb => '360x260w', - с фото эфектом
  :processor => 'Rmagick'
  ##ImageScience, Rmagick, and MiniMagick

  validates_length_of :title, :in => 4..240, :if => :is_parent?
  validates_associated :user
  validates_associated :photo_albums
  validates_as_attachment

  scope :thumbnails, lambda{ |type| {:conditions => ['thumbnail = ?',type]}}
  scope :parents, lambda{{ :conditions => {:parent_id => nil, :is_moderated => true}, :order => 'id DESC'}}
  scope :random, lambda{{ :order => 'random()'}}
  #scope :parent, lambda{{ :conditions => {:parent_id => self.id }}}
  scope :this_week, lambda {{:conditions => ['updated_at > ?', Time.now - 7.days]}}
  scope :today, lambda {{:conditions => ['created_at > ?', Time.now.ago(24.hours)]}}
  scope :this_moths, lambda {{:conditions => ['updated_at > ?', Time.now - 30.days]}}
  scope :this_week_downloads, lambda {{:conditions => ['downloads > 0 AND download_at > ?', Time.now - 7.days]}} #.at_beginning_of_week
  scope :this_moths_downloads, lambda {{:conditions => ['downloads > 0 AND download_at > ?', Time.now - 30.days]}}
  scope :this_moths_comments, lambda {{:conditions => ['comment_at > ?', Time.now - 30.days]}}
  scope :top_complaints, :conditions => 'complaint > 0', :order => 'complaint DESC'
  
  define_index do
    indexes :title, :sortable => true
    indexes [user.first_name,user.last_name], :as => :user_name
  end

  def is_jpeg?
    !(`file -i  #{self.full_filename}`).match(/image\/jp*/).nil?
  end
  
  def before_update
    if is_parent? && self.is_jpeg? && self.exif.blank?
      begin
        file = Magick::Image.read(self.full_filename).first
        ex = {}
        if file.get_exif_by_entry.size > 1
          self.exif_attr.values.collect{|v| ex[v] = file.get_exif_by_entry(v.to_s.classify)[0][1]}
          self.exif = ex
        else
          self.exif = {:software=>'0.1'}
        end
      rescue
        self.exif = {:software=>'0.1'}
      end
    end

    self.is_moderated = true #Set visible for updated photos
  end
  
  def after_save
    self.user.update_attribute(:last_activity, current_state) if is_parent? && current_state
    record = self
    #Создание строк с гистограммой для уменьшенной фотки
    if record.thumbnail.eql?('thumb')
      img = Magick::Image.read(record.full_filename).first
      img = img.quantize(NUM_COLORS)
      hist = img.color_histogram
      pixels = hist.keys.sort_by {|pixel| hist[pixel] }
      # make new Histogram objects
      pixels.each do |pixel|
        #  puts "R #{pixel.red} G #{pixel.green} B #{pixel.blue}"
        #  puts "Y #{66*pixel.red + 129*pixel.green +  25*pixel.blue}"
        #  puts "U #{-38*pixel.red -  74*pixel.green + 112*pixel.blue}"
        #  puts "V #{112*pixel.red -  94*pixel.green -  18*pixel.blue}"
        #  puts "count #{hist[pixel]}"
        #       R = Y + (1.4075 * (V - 128));
        #       G = Y - (0.3455 * (U - 128) - (0.7169 * (V - 128));
        #       B = Y + (1.7790 * (U - 128);
        #Y = R * 0.299 + G * 0.587 + B * 0.114
        #U = R * -0.169 + G * -0.332 + B * 0.500 + 128;
        #V = R* 0.500 + G * -0.419 + B * -0.0813 + 128;

        h = Histogram.create!(
          :photo_id => record.parent_id,
          :r => pixel.red, :g => pixel.green, :b => pixel.blue,
          :y => 66*pixel.red + 129*pixel.green + 25*pixel.blue,
          :u => -38*pixel.red - 74*pixel.green + 112*pixel.blue,
          :v => 112*pixel.red - 94*pixel.green - 18*pixel.blue,
          :count => hist[pixel])
      end
      record.save
    end
  end
  
=begin
== Поиск фотографий по гистограмме

Photo.find_by_color({:r => 12, :g => '200', :b => '200'},  page = nil, per_page = 30)

=== Сравниваемое число (390000) зависит от размеров изображения с которого создавалась гистограмма
подбирается в каждом случае отдельно экспериментальным способом
Q8 - select photo_id from histograms where SQRT((u - 190)^ 2 + (v - -560)^ 2) < 390000 group by photo_id order by count(photo_id) desc
Q16 - SQRT((u - 190*257)^ 2 + (v - -560*257)^ 2) < 10000*257
=== Гистограмма записывается после +after_attachment_saved+
=end
  
  def self.find_by_color(hex_color, opt = {})
    convertor = CwColorMap.new
    yuv = convertor.hex_to_yuv(hex_color)
    #    logger.debug("RGB=(#{rgb[:r]}, #{rgb[:g]}, #{rgb[:b]})")
    logger.debug("YUV=(#{yuv['y']}, #{yuv['u']}, #{yuv['v']})")

    sql = "SELECT * FROM photos as p WHERE p.id IN(
SELECT photo_id FROM histograms
WHERE SQRT((u - #{yuv['u']}*257)^ 2 + (v - #{yuv['v']}*257)^ 2) < 4000*257
GROUP BY photo_id
ORDER BY COUNT(photo_id) DESC) ORDER BY created_at DESC"

    paginate_by_sql([sql], opt)
  end

  def current_state=(st)
    @current_state = states[st]
    self.complaint += 1 if st.eql?(:complaint)
    self.updated_at = Time.now
  end

  #PAth for client thumblail
  def thumbnail
    public_filename(:crop) if self.attributes[:thumbnail].nil?
  end
  
  def thumbnail_name_for(thumbnail = nil)
    return filename if thumbnail.blank?
    ext = File.extname(filename)
    basename = File.basename(filename,ext)
    # ImageScience doesn't create gif thumbnails, only pngs
    ext.sub!(/gif$/, 'png') if attachment_options[:processor] == "ImageScience"
    #"#{basename}_#{thumbnail}#{ext}"
    Digest::MD5.hexdigest("#{basename}_#{thumbnail}")+ext
  end
 
  #поворачивает все уменьшенные размеры фотографии
  #rotate(right|left)
  def rotate(to = 'clockwise')
    case to
    when 'clockwise'
      degrees = +90
    when 'anticlockwise'
      degrees = -90
    end
    [:medium, :thumb, :crop].each do |type|
      rotate_file = full_filename(type)
      begin
        image   = Magick::ImageList.new(rotate_file)
        image   = image.rotate(degrees)
        image.write(rotate_file)
        logger.debug("Rotate file #{rotate_file}")
      rescue
        logger.warn("Failed rotate file #{rotate_file}")
      end
    end
  end

  def size
    return 1024*300 if Rails.env.eql?('development')
    attributes['size'] ? attributes['size'] : 0
  end

  def exif_to_html
    return '' if self.exif.nil?
    s = ''
    self.exif_attr.keys.sort.collect{|k|
      ex_k = self.exif_attr[k]
      s << '<dt>'+I18n.t("exif.#{ex_k.to_s}")+'</dt>'
      s << '<dd>'+(self.exif[ex_k].blank? ? '-' : self.exif[ex_k]).to_s+'</dd>'
    }
    s
  end

  def alt
    full_sanitizer.sanitize("фото: #{self.title}, [#{self.width}x#{self.height}]",{})
  end

  def keywords
    #self.tag_list.collect{|t| t.name+', ' } +
        self.title.to_s.split("\s").collect{|word| word+', '}
  end

  def to_param
    #    "#{self.id}-#{self.title.parameterize}"
    "#{self.id}-#{self.title.to_s.gsub(/[\W]/,'-')}".mb_chars[0..50]
  end

  #список фоток из альбома для просмотра
  def self.find_galery_line(photo_id, limit = @@row_out_entries)
    find_by_sql("SELECT * FROM ((SELECT * FROM #{self.table_name} WHERE id < #{photo_id} AND parent_id is NULL ORDER BY id DESC LIMIT #{limit})
           UNION ALL (SELECT * FROM #{self.table_name} WHERE id >= #{photo_id} AND parent_id is NULL ORDER BY id ASC LIMIT  #{limit + 1})) ps ORDER BY id ASC")
  end

  def created_by?(user)
    self.user.eql?(user)
  end

  def is_parent?
    self.parent_id.nil?
  end

  def full_sanitizer
    @full_sanitizer ||= HTML::FullSanitizer.new
  end
end
