class Ruhoh
  module Templaters  
    class RMustache < Mustache
      include Ruhoh::Templaters::Helpers

      class RContext < Context
    
        # Overload find method to catch helper expressions
        def find(obj, key, default = nil)
          return super unless key.to_s.index('?')
          context, helper = key.to_s.split('?')
          context = context.empty? ? obj : super(obj, context)

          self.mustache_in_stack.__send__ helper, context
        end  

      end #RContext
  
      def context
        @context ||= RContext.new(self)
      end

      def assets
        buffer = ''
        master_layout = self.context['page']['master_layout']
        sub_layout = self.context['page']['sub_layout']
        stylesheets = Ruhoh::DB.assets['stylesheets'][master_layout] || []
        stylesheets += Ruhoh::DB.assets['stylesheets'][sub_layout] || []
        stylesheets += Ruhoh::DB.assets['stylesheets']['widgets'] || []
        stylesheets.each do |url|
          buffer += "<link href=\"#{url}\" type=\"text/css\" rel=\"stylesheet\" media=\"all\">\n"
        end
        buffer += "\n"
        Ruhoh::DB.assets['scripts'].each do |s|
          buffer += "<script src=\"#{s}\"></script>\n"
        end
        
        buffer
      end
      
      def widget(name)
        return '' if self.context['page'][name.to_s].to_s == 'false'
        Ruhoh::DB.widgets[name.to_s]['layout']
      end
      
      def method_missing(name, *args, &block)
        return self.widget(name.to_s) if Ruhoh::DB.widgets.has_key?(name.to_s)
        super
      end

      def respond_to?(method)
        return true if Ruhoh::DB.widgets.has_key?(method.to_s)
        super
      end
      
    end #RMustache
  end #Templaters
end #Ruhoh
