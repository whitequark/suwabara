module Suwabara::ORM

  module ActiveRecord
    extend ActiveSupport::Concern

    attr_reader :_suwabara_files

    included do
      after_commit :write_files, on: [:create, :update]
    end

    def write_files
      if self.errors.empty? && @_suwabara_files.present?
        @_suwabara_files.values.each { |f| f.send(:write) }
        @_suwabara_files = nil
      end
    end

    private :write_files

    module ClassMethods
      attr_reader :_mounted_storages

      def mount_storage(name, klass, options={})
        name = name.to_sym

        if (unknown_opts = options.keys - [:text]).any?
          raise ArgumentError, "unknown options for mount_storage: #{unknown_opts.join(', ')}"
        end

        @_mounted_storages ||= {}
        @_mounted_storages[name] = klass

        define_method(name) do
          if read_attribute(name)
            hash = JSON.load(read_attribute(name))
            self.class._mounted_storages[name].new(self, name, hash)
          end
        end

        define_method(:"#{name}=") do |value|
          if value.is_a?(ActionDispatch::Http::UploadedFile)
            stored_file = self.class._mounted_storages[name].new(self, name,
                                  value.tempfile, value.original_filename)
          elsif value.is_a?(Suwabara::StoredFile)
            stored_file = value
          elsif value.respond_to?(:to_hash) || value.respond_to?(:to_io)
            stored_file = self.class._mounted_storages[name].new(self, name,
                                  value)
          elsif value.nil?
            write_attribute(name, nil)
            return
          else
            raise ArgumentError, "Writer #{name}= accepts " +
                    "ActionDispatch::Http::UploadedFile, Suwabara::StoredFile, IO or " +
                    "Hash"
          end

          @_suwabara_files ||= {}
          @_suwabara_files[name] = stored_file
          write_attribute(name, JSON.dump(stored_file.to_hash))
        end

        define_method(:"create_#{name}") do |filename, content|
          unless self.persisted?
            raise ActiveRecordError, "Method create_#{name} can be called only on persisted record"
          end

          stored_file = Suwabara::StoredFile.new(self, name, StringIO.new(content), filename)

          stored_file.send(:write)
          write_attribute(name, JSON.dump(stored_file.to_hash))
        end

        if options[:text]
          define_method(:"#{name}_text") do
            send(name).read
          end

          define_method(:"#{name}_text=") do |text|
            send(:"#{name}=", send(name).rewrite(text))
          end
        end
      end
    end
  end

end

ActiveRecord::Base.send :include, Suwabara::ORM::ActiveRecord
