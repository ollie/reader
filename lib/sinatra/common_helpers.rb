module Sinatra
  module CommonHelpers
    def partial_slim(template, locals = {})
      slim(template.to_sym, layout: false, locals: locals)
    end

    def title(text = nil, head: false)
      return @title = text if text
      return [@title, t('title')].compact.join(' – ') if head

      @title
    end

    def icon(filename)
      @@icon_cache ||= {}
      @@icon_cache[filename] ||= begin
        svg = Settings.root.join('public/svg/octicons', "#{filename}.svg").read
        %(<span class="octicon">#{svg}</span>)
      end
    end

    def t(key, options = nil)
      I18n.t(key, options)
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
