class String
  # 文字列を単語単位に分割した配列で返す
  def words
    pg = PragmaticTokenizer::Tokenizer.new(punctuation: :none)
    pg.tokenize(self)
  end

  def unique_words
    pt = PragmaticTokenizer::Tokenizer.new(
      language:            :en, # the language of the string you are tokenizing
      stop_words:          ['is', 'the'], # a user-supplied array of stop words (downcased)
      remove_stop_words:   true, # remove stop words
      expand_contractions: true, # Expands contractions (i.e. i'll -> i will).
      filter_languages:    [:en], # process abbreviations, contractions and stop words for this array of languages
      punctuation:         :none, # Removes all punctuation from the result.
      numbers:             :none, # Removes all tokens that include a number from the result (including Roman numerals)
      remove_emoji:        :true, # remove any emoji tokens
      remove_urls:         :true, # remove any urls
      remove_emails:       :true, # remove any emails
      remove_domains:      :true, # remove any domains
      hashtags:            :keep_and_clean, # remove the hastag prefix
      mentions:            :keep_and_clean, # remove the @ prefix
      clean:               true, # Removes tokens consisting of only hypens, underscores, or periods as well as some special characters (®, ©, ™). Also removes long tokens or tokens with a backslash.
      classic_filter:      true, # Removes dots from acronyms and 's from the end of tokens.
      downcase:            false, # do not downcase tokens
      minimum_length:      3, # remove any tokens less than 3 characters
    )
    lem = Lemmatizer.new
    # pt.tokenize(self).uniq.reject{|t| t.match(/[A-Z]/) }.map{|w| lem.lemma w}.reject{|t| t.length < 3}.uniq  # 大文字を含む単語は除外
    pt.tokenize(self).uniq.reject{|t| t.match(/[A-Z]/) }.map{|w| lem.lemma w}.uniq  # 大文字を含む単語は除外
  end

  # 文字列をセンテンス単位に分割した配列で返す
  def sentences
    ## 基本は「ピリオド or 感嘆符＋空白(改行)＋非空白文字」
    ## Mr.などの特殊例を除外: (ca. xx)などに対応するため、行頭or非文字or空白文字 + 特殊例 + ピリオド + 空白 + 非空白
    ## 名前などの略字を除外するため、1文字 + ピリオドの例も除外する（\wのところ）
    self.gsub(/(^|\W|\s)(Mr|Mrs|Ms|Mme|Sta|Sr|St|Sra|Dr|Jr|No|ca|U\.S\.A|\w)\.(?=\s+\S)/i, '\1\2.[[TMP_SPACE]]')
        .gsub(/(^|\W|\s)(I|II|III|IV|V|VI|VII|VIII|IX|X|XI|XII|XIII|XIV|XV|XVI|XVII|XVIII|XIX|XX|\p{Nl}+)\.(?=\s+\S)/, '\1\2.[[TMP_SPACE]]') # ローマ数字も除外（アルファベットで表記してるのは手動除外）
        .gsub(/(^|\W|\s)(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\.(?=\s+\S)/i, '\1\2.[[TMP_SPACE]]') # 月+.は除外（e.g. Dec., DEC.）※大文字小文字とも
        .gsub(/([\.\?\!]"?'?\s+)(\S)/, '\1[[TMP]]\2') # セリフの終わりでも区切れるように、後ろが空白じゃなくて「"」の場合も区切る（"?）
        .gsub("[[TMP_SPACE]]", "")
        .split("[[TMP]]")
  end
end
