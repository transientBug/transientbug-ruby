require 'mimemagic'

module Blocks
  module Gifs
    class Upload < AshFrame::Blocks::Base
      require :io_object, :user, title: '', tags: [], enabled: true
      optional :extension, :short_code, :created_at

      attr_reader :filename, :model

      def generate_short_code
        SecureRandom.hex(10).upcase
      end

      def storage_base
        @storage_base ||= AshFrame.root.join('public', 'images', 'gifs')
      end

      def taken_short_codes
        @taken_short_codes ||= Dir[ storage_base.join('**/*') ].map do |img|
          Pathname.new(img).relative_path_from( storage_base ).sub_ext('').to_s.gsub('/', '')
        end
      end

      def valid_short_code?
        @short_code.present? && !taken_short_codes.include?(@short_code)
      end

      def short_code
        return @short_code if valid_short_code?

        until valid_short_code?
          @short_code = generate_short_code
        end

        @short_code
      end

      def mimetype
        return @mimetype if defined?(@mimetype)

        @mimetype ||= MimeMagic.by_magic io_object.read
        io_object.rewind

        @mimetype
      end

      def extension
        @extension ||= mimetype.extensions.last
      end

      def filename
        # @filename ||= Pathname.new('').join( short_code[0..1], short_code[2..3], short_code[4..-1] ).sub_ext(".#{ extension }").to_s
        @filename ||= Pathname.new('').join( short_code ).sub_ext(".#{ extension }").to_s
      end

      def logic
        io_object.rewind

        @model = Gif.new title:      title,
                         tags:       tags,
                         enabled:    enabled,
                         short_code: short_code,
                         filename:   filename,
                         user:       user

        @model.created_at = created_at if created_at.present?

        unless @model.valid?
          add_error message: 'Gif is not valid', meta: @model.errors
          return
        end

        output_path = storage_base.join filename
        first_frame_path = storage_base.join 'first', filename

        output_path.parent.mkpath
        first_frame_path.parent.mkpath

        mm_gif = MiniMagick::Image.read io_object
        mm_gif.frames.first.write first_frame_path

        io_object.rewind

        output_path.write io_object.read

        @model.save
      end
    end
  end
end
