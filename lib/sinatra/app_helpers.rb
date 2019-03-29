module Sinatra
  module AppHelpers
    def json(data)
      MultiJson.dump(data, pretty: !Settings.production?)
    end

    def mustache(view_path, locals = {})
      template = read_mustache_template(view_path)
      Mustache.render(template, locals)
    end

    def read_mustache_template(view_path)
      @mustache_cache ||= {}
      @mustache_cache[view_path] ||= File.read("#{settings.views}/#{view_path}.mustache")
    end

    def item_data_for_mustache(item, index)
      {
        active:   index.zero?,
        item_url: api_item_path(item.id),
        title:    item.title,
        read:     item.read
      }
    end
  end
end
