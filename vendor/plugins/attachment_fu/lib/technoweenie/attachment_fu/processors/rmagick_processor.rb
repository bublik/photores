require 'RMagick'
include Magick
module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Processors
      module RmagickProcessor
        def self.included(base)
          base.send :extend, ClassMethods
          base.alias_method_chain :process_attachment, :processing
        end

        module ClassMethods
          # Yields a block containing an RMagick Image for the given binary data.
          def with_image(file, &block)
            begin
              binary_data = file.is_a?(Magick::Image) ? file : Magick::Image.read(file).first unless !Object.const_defined?(:Magick)
              GC.start
            rescue
              # Log the failure to load the image.  This should match ::Magick::ImageMagickError
              # but that would cause acts_as_attachment to require rmagick.
              logger.debug("Exception working with image: #{$!}")
              binary_data = nil
            end
            block.call binary_data if block && binary_data
          ensure
            !binary_data.nil?
          end
        end

        protected
        def process_attachment_with_processing
          return unless process_attachment_without_processing
          with_image do |img|
            resize_image_or_thumbnail! img
            self.width  = img.columns if respond_to?(:width)
            self.height = img.rows    if respond_to?(:height)
            callback_with_args :after_resize, img
          end if image?
        end

        # Performs the actual resizing operation for a thumbnail
        def resize_image(img, size)
          size = size.first if size.is_a?(Array) && size.length == 1 && !size.first.is_a?(Fixnum)
          if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
            size = [size, size] if size.is_a?(Fixnum)
            img.thumbnail!(*size)
          elsif size.include? "!"
            size = size.split('x').collect{|r| r.to_i}
            img.crop_resized!(size[0], size[1], Magick::CenterGravity)
            img.border!(1, 1, "#f0f0ff")
            #text = Magick::Draw.new
            #            text.annotate(img, 0, 0, 5, -15, "Rails in UA") {
            #              self.gravity = Magick::EastGravity
            #              self.rotation = -90
            #              self.pointsize = 10
            #              self.stroke = 'transparent'
            #              self.fill = '#ad2525'
            #              self.font_weight = Magick::BoldWeight
            #              self.font_family = 'Helvetica'
            #            } 
          elsif size.include? "w"
            size.gsub!(/w/,'')
            img.change_geometry!(size.to_s) { |cols, rows, image| image.resize!(cols<1 ? 1 : cols, rows<1 ? 1 : rows)}
            # Watermark
            img = add_logo(img)
            #############################
            img = add_photo_effect(img)
            img.trim!
          else
            img.change_geometry(size.to_s) { |cols, rows, image| image.resize!(cols<1 ? 1 : cols, rows<1 ? 1 : rows) }
            img = add_logo(img)
          end
          img.strip! unless attachment_options[:keep_profile]
          self.temp_path = write_to_temp_file(img.to_blob)
        end
        
        private
        def add_photo_effect(img)
          #Эфект полароида с тенью
          img.border!(12, 12, "#f0f0ff")

          # Bend the image
          img.background_color = "none"
          amplitude = img.columns * 0.01        # vary according to taste
          # Make the shadow
          shadow = img.flop
          shadow = shadow.colorize(1, 1, 1, "gray75")     # shadow color can vary to taste
          shadow.background_color = "white"       # was "none"
          shadow.border!(6, 6, "white")
          shadow = shadow.blur_image(0, 2)        # shadow blurriness can vary according to taste
          # Composite image over shadow. The y-axis adjustment can vary according to taste.
          shadow.composite(img, amplitude - 1 , amplitude - 1, Magick::OverCompositeOp)
        end
        
        def add_logo(img, mark_text = APP_CONFIG['domain'])
          # Make a watermark from the word "RMagick"
          #add border as photo
          img.border!(2, 2, "#f0f0ff")

          mark = Magick::Image.new(190, 40) {self.background_color = "none"}
          gc = Magick::Draw.new

          gc.annotate(mark, 0, 0, 0, 0,  mark_text.upcase) do
            gc.gravity = Magick::CenterGravity
            gc.pointsize = 13
#            if RUBY_PLATFORM =~ /mswin32/
#              gc.font_family = "Georgia"
#            else
#              gc.font_family = "Times"
#            end
            gc.fill = "#ccc"
            gc.stroke = "none"
          end
          # mark = mark.wave(2.5, 70) #rotate(-90) #
          # Composite the watermark in the lower right (southeast) corner.
          img.watermark(mark, 0.5, 1, Magick::SouthEastGravity)
        end
      end
    end
  end
end
