module Sinatra
  module Routing
    def Route(hash)
      route_name = hash.keys.first
      route_path = hash[route_name]

      helpers do
        define_method("#{route_name}_path") do |*args|
          id        = args.first if args.first && !args.first.is_a?(Hash)
          qs_params = args.last  if args.last.is_a?(Hash)

          path =
            if route_path =~ /:id/
              raise ArgumentError, "Missing :id parameter for route #{route_path}" unless id
              route_path.gsub(':id', id.to_s)
            else
              route_path
            end

          path += qs(qs_params) if qs_params
          path
        end
      end

      route_path
    end
  end
end
