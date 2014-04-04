module Suwabara
  class StoredFile
    attr_reader :name, :size

    def self.storage_root
      Suwabara.default_root
    end

    def initialize(model, mounted_as, source, original_name=nil)
      @model      = model
      @mounted_as = mounted_as
      @file       = nil

      if source.respond_to?(:to_io)
        file = source.to_io

        if original_name.nil? && source.respond_to?(:to_path)
          original_name = source.to_path
        end

        initialize_from_io(file, File.basename(original_name))
      elsif source.is_a?(StringIO)
        initialize_from_io(source, File.basename(original_name))
      elsif source.respond_to?(:to_hash)
        initialize_from_hash(source.to_hash)
      else
        raise ArgumentError, "Suwabara::StoredFile can be initialized from IO or Hash"
      end

      freeze
    end

    def initialize_from_io(file, original_name)
      @name    = original_name
      @size    = file.size
      @file    = file
    end

    def initialize_from_hash(hash)
      @name    = hash["name"]
      @size    = hash["size"]
    end

    private :initialize_from_io, :initialize_from_hash

    def content_type
      MIME::Types.of(File.extname(@name)).first.content_type
    end

    def read
      File.read(full_path)
    end

    def full_path
      self.class.storage_root.join(self.storage)
    end

    def url
      url_for(self.storage)
    end

    def rename(new_name)
      with_io { |io| self.class.new(@model, @mounted_as, io, new_name) }
    end

    def rewrite(new_body)
      io = Tempfile.new('suwabara')
      io.write(new_body)

      self.class.new(@model, @mounted_as, io, @name)
    ensure
      io.close!
    end

    def with_io
      io = to_io

      yield io
    ensure
      io.close
    end

    def to_hash
      {
        "name"    => @name,
        "size"    => @size,
        "storage" => self.storage
      }
    end

    def to_io
      File.open(full_path, 'r')
    end

    def ==(other)
      other.instance_of?(self.class) &&
        @name    == other.name &&
        self.storage == other.storage
    end

    def storage
      storage_for(@name)
    end

    private

    def url_for(path)
      "/#{URI.escape(path.to_s)}"
    end

    def partitions(model_id = @model.id)
      model_id.to_s.
        rjust(9, '0').
        match(/^(\d+)(\d{3})(\d{3})$/).
        captures.
        join('/')
    end

    def storage_for(name)
      return unless @model.id
      File.join(partitions, name)
    end

    def write
      return unless @file || @model.id

      full_path.parent.mkpath

      File.open(full_path, 'wb') do |file|
        @file.rewind
        file.write @file.read
      end
    end
  end
end
