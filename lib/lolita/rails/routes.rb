module ActionDispatch::Routing

  class RouteSet

    # Each time when #draw method is called this is called as well.
    # It creates :left_side_navigation tree and call callbacks
    # Lolita#before_routes_loaded and Lolita#after_routes_loaded
    def draw_with_lolita  *args,&block
      Lolita.run(:before_routes_loaded)
      draw_without_lolita *args,&block
      Lolita.run(:after_routes_loaded)
    end

    alias_method_chain :draw, :lolita
  end

  class Mapper

    # Every module, that is used with lolita and has routes, need to have
    # <code>resource method</code>, for example, lolita_rest, that should be added
    # to ActionDispatch::Routing::Mapper class, as a *protected* method.
    # Module can automaticliy add resource route or allow user to do it.
    # It accepts some useful options
    # * <tt>:module</tt>
    # * <tt>:path</tt>
    # * <tt>:as</tt>
    # * <tt>:path_prefix</tt>
    # * <tt>:controller</tt>
    # * <tt>:class_name</tt>
    # * <tt>:singular</tt>
    # ====Example
    #     Lolita.add_module Lolita::Gallery,:route=>:gallery
    #     # in route.rb
    #     lolita_for :galleries
    #     # lolita_for try to call :lolita_gallery in Mapper class
    def lolita_for *resources
      options = resources.extract_options!

      options[:as]          ||= @scope[:as]     if @scope[:as].present?
      options[:module]      ||= @scope[:module] if @scope[:module].present?
      options[:path_prefix] ||= @scope[:path]   if @scope[:path].present?
      resources.map!(&:to_sym)
      all_resource_classes=[]
      resources.each{|resource|
        mapping = Lolita.add_mapping(resource,options)
        Lolita.resources[mapping.name] = mapping
        target_class = mapping.to

  #TODO refactor all these variables
        all_resource_classes<<target_class

        lolita_scope mapping.name do
          yield if block_given?

          with_lolita_exclusive_scope mapping.fullpath,mapping.path do

            # if not defined lolita default configuration in model, than can't use :rest

            # if !target_class.respond_to?(:lolita) && !Lolita::routes[mapping.name]
            #    raise Lolita::NotFound, "Lolita not found in #{target_class}. Include Lolita::Configuration"
            # elsif target_class.respond_to?(:lolita) && target_class.instance_variable_get(:@lolita).nil?
            #   warn("Lolita is not initialized, call `lolita` in #{target_class}")
            #   route = Lolita.routes[mapping.name] || Lolita.default_route
            #   #raise Lolita::NotInitialized, "Call lolita method in #{target_class}."
            # else
            #   route=Lolita.routes[mapping.name] || Lolita.default_route
            # end
            route = Lolita.routes[mapping.name] || Lolita.default_route
            unless route
              raise Lolita::ModuleNotFound, "Module #{mapping.name.to_s.capitalize} not found!"
            end
            send(:"lolita_#{route}_route",mapping,mapping.controllers)

            Lolita.conditional_routes(target_class).each do |route_name|
              send(:"lolita_#{route_name}_route",mapping,mapping.controllers)
            end
          end

        end

        mapping.add_to_navigation_tree
      }
      Lolita.common_routes(all_resource_classes).each do |route_name|
        send(:"lolita_#{route_name}_route")
      end
      # rescues sql exception when migration for new model is executed
    rescue ActiveRecord::StatementInvalid
      Rails.logger.debug "Executing lolita_for got an error: #{$!}"
      nil
    end

    protected

    def lolita_scope scope
      constraint = lambda do |request|
        request.env["lolita.mapping"] = Lolita.mappings[scope]
        true
      end

      constraints(constraint) do
        yield
      end
    end

    def with_lolita_exclusive_scope new_path,new_as
      old_as, old_path, old_module = @scope[:as], @scope[:path], @scope[:module]
      @scope[:as], @scope[:path], @scope[:module] = new_as, new_path, nil
      yield
    ensure
      @scope[:as], @scope[:path], @scope[:module] = old_as, old_path, old_module
    end

    private

    def generator_detected?
      defined?(Rails::Generators)
    end
  end
end
