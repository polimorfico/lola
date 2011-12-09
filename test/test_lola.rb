require 'helper'

class TestLola < Test::Unit::TestCase
  def teardown
    Lola.default_locale = :en # restore default
  end

  def test_default_languages
    assert_equal ['Avestan', 'AE'], Lola.languages[2]
  end

  def test_localized_languages
    Lola.default_locale = :es
    assert_equal ["Afar", 'AA'], Lola.languages[0]
  end

  def test_single_localized_languages_call
    # Check that we are working with the default
    assert_equal ['Afar', 'AA'], Lola.languages[0]

    # Switch to a different locale for one call
    assert_equal ["Afar", 'AA'], Lola.languages(:locale => 'es')[0]

    # Make sure that we are back in the default locale
    assert_equal ['Afar', 'AA'], Lola.languages[0]
  end

  def test_language_name
    assert_equal 'English', Lola.language_name('EN')
    assert_equal 'English', Lola.language_name('en')
    assert_nil Lola.language_name('')
    assert_nil Lola.language_name(nil)
  end

  def test_localized_language_name
    assert_equal 'English', Lola.language_name('EN')
    assert_equal 'Griego', Lola.language_name('EL', :locale => :es)
    Lola.default_locale = :es
    assert_equal 'Griego', Lola.language_name('EL')
  end

  def test_language_code
    assert_equal 'ES', Lola.language_code('Spanish')
    assert_equal 'ES', Lola.language_code('spanish')
    assert_equal 'DE', Lola.language_code('German')
  end

  def test_localized_language_code
    assert_equal 'EL', Lola.language_code('Griego', :locale => :es)
    Lola.default_locale = :es
    assert_equal 'EL', Lola.language_code('Griego')
  end

  def test_language_codes
    assert_equal 'AA', Lola.language_codes.first
    assert_equal 187, Lola.language_codes.length
  end

  def test_language_names
    assert_equal 'Afar', Lola.language_names.first
    assert_equal 187, Lola.language_names.length
  end

  def test_excluded_languages
      Lola.excluded_languages = [ 'EN', 'ES' ]
      languages = Lola.languages
      assert !languages.include?( ["English", "EN"] )
      assert !languages.include?( ["Spanish", "ES"] )
      assert languages.include?( ["German", "DE"] )
      Lola.excluded_languages = [ ]
  end

  def test_prepended_languages
    en_original_index = Lola.languages.index(['English', 'EN'])
    Lola.priority_languages = %w(EN ES DE)
    languages = Lola.languages
    assert_equal 0, languages.index(['English', 'EN'])
    assert_equal 1, languages.index(['Spanish', 'ES'])
    assert_equal 2, languages.index(['German', 'DE'])

    assert_equal 3 + en_original_index, languages.rindex(['English', 'EN'])

    Lola.priority_languages = []
  end

  def test_unsupported_locale
    assert_raises Lola::UnavailableLocale do
      Lola.languages(:locale => :latin)
    end
  end

  def test_special_characters_dont_rails_an_exception
    assert_nil(Lola.language_code('???'))
  end
end
