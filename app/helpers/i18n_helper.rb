module I18nHelper
  def translate(key, options={})
    super(key, options.merge(raise: true))
  rescue I18n::MissingTranslationData
    # juvenileで翻訳が見つからないときは、jaかenのファイルを見に行く
    locale = I18n.locale.slice(0,2).to_sym  # 読み込み順序依存してそうなので、search_helperのlang_localeを直接定義
    I18n.with_locale(locale) do
      super(key, options)
    end
  end
  alias :t :translate
end
