require 'yaml'

module Lola
  class << self
    attr_accessor :default_locale, :default_language, :excluded_languages, :priority_languages
  end

  self.default_locale = :en
  self.default_language = 'EN'
  self.excluded_languages = []
  self.priority_languages = []

  @data_path = File.join(File.dirname(__FILE__), '..', 'data')

  # Raised when attemting to switch to a locale which does not exist
  class UnavailableLocale < RuntimeError; end
  
  # Returns a list of all languages
  def self.languages(options={})
    # Use specified locale or fall back to default locale
    locale = options.delete(:locale) || @default_locale
    locale = available_locales.include?(locale) ? locale.to_s : @default_locale.to_s

    # Load the country list for the specified locale
    @languages ||= {}
    unless @languages[locale]
      # Check if data in the specified locale is available
      localized_data = File.join(@data_path, "#{locale}.yml")
      unless File.exists?(localized_data)
        raise(UnavailableLocale, "Could not load languages for '#{locale}' locale")
      end

      # As the data exists, load it
      @languages[locale] = YAML.load_file(localized_data)
    end

    # Return data after filtering excluded languages and prepending prepended languages
    result = @languages[locale].reject { |c| excluded_languages.include?( c[1] ) }
    priority_languages.map { |code| [ search_collection(result, code, 1, 0), code ] } + result
  end

  # Returns the language name corresponding to the supplied language code, optionally using the specified locale.
  #  Carmen::language_name('EN') => 'English'
  #  Carmen::language_name('ES', :locale => :es) => 'Español'
  def self.language_name(language_code, options={})
    search_collection(languages(options), language_code, 1, 0)
  end

  # Returns the language code corresponding to the supplied language name
  #  Carmen::language_code('English') => 'EN'
  def self.language_code(language_name, options={})
    search_collection(languages(options), language_name, 0, 1)
  end

  # Returns an array of all language codes
  #  Carmen::language_codes => ['AA', 'AB', 'AE', ... ]
  def self.language_codes
    languages.map {|c| c[1] }
  end

  # Returns an array of all language names, optionally using the specified locale.
  #  Carmen::language_names => ['Afar', 'Abkhazian', Avestan', ... ]
  #  Carmen::language_names(:locale => :es) => ['Afrikaans', 'Árabe', 'Bengalí', ... ]
  def self.language_names(options={})
    languages(options).map {|c| c[0] }
  end

  protected
  def self.available_locales
    locales = Array.new
    Dir.glob("#{@data_path}/*.yml") do |filename|
      locales << File.basename(filename, '.yml').to_sym
    end
    locales
  end
  
  def self.search_collection(collection, value, index_to_match, index_to_retrieve)
    return nil if collection.nil? || value.nil? || value.empty?
    collection.each do |m|
      return m[index_to_retrieve] if m[index_to_match].downcase == value.downcase
    end
    # In case we didn't get any results we'll try a broader search (via Regexp)
    collection.each do |m|
      return m[index_to_retrieve] if m[index_to_match].downcase.match(Regexp.escape(value.downcase))
    end
    nil
  end
end

if defined?(Rails)
  require 'lola/railtie'
end