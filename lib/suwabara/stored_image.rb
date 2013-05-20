module Suwabara

  class StoredImage < StoredFile
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
