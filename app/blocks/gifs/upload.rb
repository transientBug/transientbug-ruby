module Blocks
  module Gifs
    class Upload < AshFrame::Blocks::Base
      include AshFrame::Blocks::Errors

      require :io_object, :extension, :user, title: '', tags: [], enabled: true

      def generate_short_code
        SecureRandom.hex(5).upcase
      end

      def taken_short_codes
        @taken_short_codes ||= Dir[ AshFrame.root.join('public', 'images', 'gifs', '**/*') ].map do |img|
          name = img.gsub( AshFrame.root.join('public', 'images', 'gifs').to_s + '/', '' ).split '.'
          name.pop
          name.join '.'
        end
      end

      def logic
        short_code = generate_short_code
        while taken_short_codes.include? short_code
          short_code = generate_short_code
        end

        filename = [ short_code, extension ].join '.'

        gif = Gif.new title:      title,
                      tags:       tags,
                      enabled:    enabled,
                      short_code: short_code,
                      filename:   filename,
                      user:       user

        unless gif.valid?
          add_error message: 'Gif is not valid', meta: gif.errors
          return
        end

        output_path = AshFrame.root.join 'public', 'images', 'gifs', filename
        first_frame_path = AshFrame.root.join 'public', 'images', 'gifs', 'first', filename

        Tempfile.open short_code do |f|
          f.binmode
          f.write io_object.read
          f.rewind

          mm_gif = MiniMagick::Image.open f.path
          mm_gif.frames.first.write first_frame_path

          f.rewind

          output_path.write f.read
        end

        gif.save
      end
    end
  end
end
