module Sinatra
  module Routing
    module Helpers
      def qs(hash)
        params = self.params.except('captures', 'splat', 'id')
        params.merge!(hash.stringify_keys)
        params.scrub!

        encoded_params = serialize_qs(params)

        if encoded_params.empty?
          ''
        else
          "?#{encoded_params}"
        end
      end

      private

      def serialize_qs(params)
        serialized_params = []

        params.each do |key, value|
          next if value.is_a?(Hash)
          serialized_params << "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
        end

        serialized_params.join('&')
      end
    end

    def self.registered(app)
      app.helpers Routing::Helpers
    end

    def Route(hash)
      route_name = hash.keys.first
      route_path = hash[route_name]

      helpers do
        define_method("#{route_name}_path") do |*args|
          ids       = args.reject { |arg| arg.is_a?(Hash) }
          qs_params = args.select { |arg| arg.is_a?(Hash) }.first

          path = route_path.dup

          while id_key_match = path.match(/:([a-z]+_)?id/)
            id_key   = id_key_match[0]
            id_value = ids.shift

            raise ArgumentError, "Missing #{id_key} parameter for route #{route_path}" unless id_value

            # Prevent infinite loop or id_value being nil
            id_value = id_value.gsub(':', '!') if id_value.is_a?(String)
            path.gsub!(id_key, id_value.to_s)
          end

          path.gsub!('!', ':')
          path += qs(qs_params) if qs_params
          path
        end
      end

      route_path
    end
  end
end
