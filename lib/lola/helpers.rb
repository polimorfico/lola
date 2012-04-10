module ActionView
  module Helpers
    module FormOptionsHelper
      # Return select and option tags for the given object and method, using language_options_for_select to generate the list of option tags.
      def language_select(object, method, priority_languages = nil, options = {}, html_options = {})
        InstanceTag.new(object, method, self, options.delete(:object)).to_language_select_tag(priority_languages, options, html_options)
      end

      # Returns a string of option tags for pretty much any language in the world. Supply a language name as +selected+ to
      # have it marked as the selected option tag. You can also supply a list of language codes as additional parameters, so
      # that they will be listed above the rest of the (long) list.
      def language_options_for_select(selected = nil, *priority_language_codes)
        language_options = ""

        unless priority_language_codes.empty?
          priority_languages = Lola::languages.select do |pair| name, code = pair
            priority_language_codes.include?(code)
          end
          unless priority_languages.empty?
            language_options += options_for_select(priority_languages, selected)
            language_options += "\n<option value=\"\" disabled=\"disabled\">-------------</option>\n"
          end
        end

        language_options = language_options + options_for_select(Lola.languages, priority_language_codes.include?(selected) ? nil : selected)
        return language_options.html_safe
      end
    end

    class InstanceTag
      def to_language_select_tag(priority_languages, options, html_options)
        html_options = html_options.stringify_keys
        add_default_name_and_id(html_options)
        value = value(object)
        opts = add_options(language_options_for_select(value, *priority_languages), options, value)
        content_tag("select", opts, html_options)
      end
    end

    class FormBuilder
      def language_select(method, priority_languages = nil, options = {}, html_options = {})
        @template.language_select(@object_name, method, priority_languages, options.merge(:object => @object), html_options)
      end
    end
  end
end