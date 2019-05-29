module Stats
  module Parser
    class Meta
      attr_accessor :model

      def initialize(model)
        @model = model
      end

      def self.structure
        collection = []
        Stats::Parser::Meta.all.each { |model| collection << Stats::Parser::Meta.new(model).details }
        { database: Rails.configuration.database_configuration["production"], models: collection }
      end

      def self.all
        ActiveRecord::Base.descendants.reject {|model| model.table_name.nil? || model.name.include?('HABTM_')}
      end

      def details
        {
            name: model,
            table_name: model.table_name,
            associations: associations,
            columns: columns_detail,
            instance_methods: instance_methods
        }
      end

      def columns_detail
        columns = model.columns_hash.values
        columns.map! do |v|
          {
              name: v.name,
              type: v.sql_type_metadata.type,
              sql_type: v.sql_type_metadata.sql_type,
              limit: v.sql_type_metadata.limit,
              precision: v.sql_type_metadata.precision,
              scale: v.sql_type_metadata.scale,
              default: v.default_function,
              null: v.null
          }
        end
        columns
      end

      def instance_methods
        model.instance_methods(false).collect {|_method| {name: _method.to_s, body: model.instance_method(_method.to_sym).source.split("\n")}}
      end

      def associations
        model.reflect_on_all_associations.collect do |reflection|
          {
              type: reflection.macro,
              name: reflection.name,
              class_name: reflection.options[:polymorphic] ? '' : reflection.klass,
              options: reflection.options,
              plural_name: reflection.plural_name
          }
        end
      end
    end
  end
end
