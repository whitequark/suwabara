module Suwabara

  class StoredImage < StoredFile

    attr_reader :width, :height

    def initialize_from_io(file, original_name)
      image = MiniMagick::Image.read(file)

      @width  = image[:width]
      @height = image[:height]

      super
    end

    def initialize_from_hash(hash)
      @width  = hash["width"]
      @height = hash["height"]

      super
    end

    def to_hash
      {
        "width"  => @width,
        "height" => @height,
      }.merge(super)
    end

    def url(transform = nil)
      transform = ImageTransform.parse(transform)

      if transform.present?
        path = Pathname.new(@storage)
        path_with_transform = path.parent.join(transform.to_s, path.basename)

        url_for(path_with_transform)
      else
        super()
      end
    end
  end

end
