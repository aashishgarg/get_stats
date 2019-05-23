module Stats
  module Parser
    class JSON
      # --- Attribute Accessors --- #
      attr_accessor :classes, :modules

      def initialize
        @collection, @classes, @modules = [], [], []
      end

      def iterate(collection)
        collection.each do |item|
          _methods = item[:children].select {|child| child[:type] == 'method'}
          if item[:type] == 'class'
            @classes << {name: item[:name], methods: _methods, body: item[:body]}
            iterate(item[:children])

          elsif item[:type] == 'modules'
            @classes << {name: item[:name], methods: _methods, body: item[:body]}
            iterate(item[:children])
          end
        end
        { classes: @classes, modules: @modules }
      end

      def class_item(name)
        @collection[0][:children].select {|item| item[:type] == 'class' && item[:name] == name }.last
      end

      def methods_list(class_name)
        methods = class_item(class_name)[:children].select {|y| y[:type] == 'method'}
        methods.collect do |item2|
          {name: item2[:name], level: item2[:level], args: item2[:arguments]}
        end unless methods.empty?
        methods
      end

      def class_methods_hash(collection)
        models = collection[0][:children].select {|item| item[:file_type] == 'model'}
        models.map do |child1|
          methods = child1[:children].select {|y| y[:type] == 'method'}
          method_hashes = methods.collect do |item2|
            {name: item2[:name], level: item2[:level], args: item2[:arguments]}
          end

          {child1[:name] => {body: child1[:body], method_hashes: method_hashes}}
        end
      end
    end
  end
end