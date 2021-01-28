module I18nHelper
  def translate(key, options={})
    super(key, options.merge(raise: true))
  rescue I18n::MissingTranslationData
    # juvenileで翻訳が見つからないときは、jaかenのファイルを見に行く
    I18n.with_locale(lang_locale) do
      super(key, options)
    end
  end
  alias :t :translate
end
