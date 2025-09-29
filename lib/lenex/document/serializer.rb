# frozen_string_literal: true

require 'nokogiri'

module Lenex
  class Document
    # Serialises a {Lenex::Document} into Lenex XML.
    class Serializer
      ROOT_ELEMENT = 'LENEX'

      def initialize(document)
        @document = document
      end

      # Generates a Lenex XML document from the provided {Lenex::Document}.
      #
      # @return [String] UTF-8 encoded Lenex XML
      def to_xml
        lenex = document.build_lenex

        Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          write_lenex(xml, lenex)
        end.to_xml
      end

      def self.singular_element(container_name)
        return container_name unless container_name.end_with?('S')
        return container_name[0..-2] if container_name.end_with?('SS')

        container_name.sub(/IES\z/, 'Y').sub(/S\z/, '')
      end

      private

      attr_reader :document

      def write_lenex(xml, lenex)
        attributes = { 'version' => lenex.version }
        revision = lenex.revision
        attributes['revision'] = revision if present?(revision)

        xml.send(ROOT_ELEMENT, attributes) do
          NodeSerializer.write(xml, 'CONSTRUCTOR', lenex.constructor)
          write_collection(xml, 'MEETS', lenex.meets)
          write_collection(xml, 'RECORDLISTS', lenex.record_lists)
          write_collection(xml, 'TIMESTANDARDLISTS', lenex.time_standard_lists)
        end
      end

      def write_collection(xml, container_name, collection)
        return if collection.empty?

        item_name = self.class.singular_element(container_name)
        xml.send(container_name) do
          collection.each do |item|
            NodeSerializer.write(xml, item_name, item)
          end
        end
      end

      def present?(value)
        !(value.nil? || value.to_s.strip.empty?)
      end

      # Serialises Lenex object model instances using their attribute maps.
      class NodeSerializer
        def self.write(xml, element_name, object)
          return if object.nil?

          raise ArgumentError, "Cannot serialise #{object.class} with #{name}" if object.is_a?(Hash)

          new(xml, element_name, object).write
        end

        def self.attribute_map_for(klass)
          attribute_cache[klass] ||= build_attribute_map(klass)
        end

        def self.attribute_cache
          @attribute_cache ||= {}
        end
        private_class_method :attribute_cache

        def self.build_attribute_map(klass)
          return {} unless klass.const_defined?(:ATTRIBUTES, false)

          attributes = klass.const_get(:ATTRIBUTES)
          attributes.each_with_object({}) do |(attribute_name, definition), mapping|
            key = definition.is_a?(Hash) ? definition.fetch(:key) : definition
            mapping[key.to_sym] = attribute_name
          end
        end
        private_class_method :build_attribute_map

        def initialize(xml, element_name, object)
          @xml = xml
          @element_name = element_name
          @object = object
        end

        def write
          attributes = collect_attributes
          children = collect_children

          return emit_empty_element(attributes) if children.empty?

          emit_nested_element(attributes, children)
        end

        def write_child(name, value)
          return write_array_child(name, value) if value.is_a?(Array)

          self.class.write(xml, element_name_for(name), value)
        end

        private

        attr_reader :xml, :element_name, :object

        def collect_attributes
          attribute_map = self.class.attribute_map_for(object.class)

          attribute_map.each_with_object({}) do |(key, xml_name), collected|
            value = fetch_attribute_value(key)
            next if value.nil?

            collected[xml_name] = value.to_s
          end
        end

        def fetch_attribute_value(key)
          object.public_send(key)
        rescue NoMethodError
          nil
        end

        def collect_children
          object.instance_variables.each_with_object({}) do |ivar, collected|
            next if attribute_instance_variables.include?(ivar.to_s)

            value = object.instance_variable_get(ivar)
            next if skip_child_value?(value)

            collected[ivar_name(ivar)] = value
          end
        end

        def attribute_instance_variables
          self.class.attribute_map_for(object.class).keys.map { |key| "@#{key}" }
        end

        def ivar_name(ivar)
          ivar.to_s.delete_prefix('@').to_sym
        end

        def element_name_for(name)
          name.to_s.delete('_').upcase
        end

        def emit_empty_element(attributes)
          xml.send(element_name, attributes)
        end

        def emit_nested_element(attributes, children)
          xml.send(element_name, attributes) do
            children.each do |name, value|
              write_child(name, value)
            end
          end
        end

        def write_array_child(name, values)
          return if values.empty?

          container_name = element_name_for(name)
          item_name = Serializer.singular_element(container_name)

          xml.send(container_name) do
            values.each do |value|
              self.class.write(xml, item_name, value)
            end
          end
        end

        def skip_child_value?(value)
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end
    end
  end
end
