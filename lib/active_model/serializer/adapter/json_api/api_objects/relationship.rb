module ActiveModel
  class Serializer
    module Adapter
      class JsonApi
        module ApiObjects
          class Relationship
            def initialize(parent_serializer, serializer, options = {}, links = {}, meta = nil)
              @object = parent_serializer.object
              @scope = parent_serializer.scope

              @options = options
              @data = data_for(serializer, options)
              @links = links.each_with_object({}) do |(key, value), hash|
                hash[key] = ActiveModelSerializers::Adapter::JsonApi::Link.new(parent_serializer, value).as_json
              end
              @meta = meta.respond_to?(:call) ? parent_serializer.instance_eval(&meta) : meta
            end

            def as_json
              hash = {}
              hash[:data] = data if options[:include_data]
              links = self.links
              hash[:links] = links if links.any?
              meta = self.meta
              hash[:meta] = meta if meta

              hash
            end

            protected

            attr_reader :object, :scope, :data, :options, :links, :meta

            private

            def data_for(serializer, options)
              if serializer.respond_to?(:each)
                serializer.map { |s| ResourceIdentifier.new(s).as_json }
              else
                if options[:virtual_value]
                  options[:virtual_value]
                elsif serializer && serializer.object
                  ResourceIdentifier.new(serializer).as_json
                end
              end
            end
          end
        end
      end
    end
  end
end
