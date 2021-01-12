module Sinatra
  module CommonHelpers
    def partial_slim(template, locals = {})
      slim(template.to_sym, layout: false, locals: locals)
    end

    def version_asset(path)
      file_path = Settings.root.join("public#{path}")

      return path unless file_path.file?

      "#{path}?v=#{file_path.mtime.to_i}"
    end

    def title(text = nil, head: false)
      return @title = text if text
      return [@title, t('title')].compact.join(' – ') if head

      @title
    end

    def icon(filename)
      @@icon_cache ||= {} # rubocop:disable Style/ClassVars
      @@icon_cache[filename] ||= begin
        filename = filename.to_s.gsub('_', '-')
        filename = "#{filename}-16" unless filename =~ /-\d+$/
        svg = Settings.root.join('public/svg/octicons', "#{filename}.svg").read
        %(<span class="octicon">#{svg}</span>)
      end
    end

    def t(key, options = nil)
      if options
        I18n.t(key, **options)
      else
        I18n.t(key)
      end
    end

    def l(key, options = nil)
      if options
        I18n.l(key, **options)
      else
        I18n.l(key)
      end
    end
  end
end
