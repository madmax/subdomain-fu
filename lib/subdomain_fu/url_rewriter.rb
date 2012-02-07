require 'action_dispatch/routing/route_set'

module ActionDispatch
  module Routing
    class RouteSet #:nodoc:
            
      # this will require class with subdomain and regexp? method
      def url_for_with_subdomains(options, path_segments=nil)
        if options[:use_route] && route = named_routes.get(options[:use_route]) 
          # get subdomain constraint (need respond to subdomain mathod)     
          subdomain_constrain = route.app.instance_variable_get("@constraints").to_a.find { |constraint| constraint.respond_to?(:subdomain)}
          
          # add subdomain option if subdomain constrain is not regexp
          options[:subdomain] ||= subdomain_constrain.subdomain if subdomain_constrain && !subdomain_constrain.regexp?
        end
        
        # remove subdomain (it will be rewrited to host)
        subdomain = options.delete(:subdomain)
        
        if SubdomainFu.needs_rewrite?(subdomain, options[:host]) || options[:only_path] == false
          options[:only_path] = false if SubdomainFu.override_only_path?
          options[:host] = SubdomainFu.rewrite_host_for_subdomains(subdomain, options[:host])
        end
        
        url_for_without_subdomains(options)
      end
      alias_method_chain :url_for, :subdomains
    end
  end
end
