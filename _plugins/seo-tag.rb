module Jekyll
  class SeoTag < Liquid::Tag
    alias_method :old_template_path, :template_path

    def template_path
      @template_path ||= begin
        override = File.expand_path '../_includes/seo.html', File.dirname(__FILE__)
        override unless !File.exists? override
      end
      @template_path ||= old_template_path
    end
  end
end

Liquid::Template.register_tag('seo', Jekyll::SeoTag)
