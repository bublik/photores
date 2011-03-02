class PhotoNote < ActiveRecord::Base
  include ActionView::Helpers::TextHelper

  belongs_to :user
  belongs_to :photo

  validates_presence_of :x1, :y1, :height, :width, :note

  def before_validation
    sanitar = HTML::FullSanitizer.new
    self.note = sanitar.sanitize(self.note.to_s.strip.mb_chars[0..254])
  end

  def json_attr
    h = attributes.dup
    h.merge!({'note' => "<strong>#{user.full_name}:</strong> <br/>" + note.mb_chars.gsub(/(.{1,25})(\s+|\Z)/, "\\1\n") })
  end
  
end
