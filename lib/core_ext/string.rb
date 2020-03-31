class String
  # 文字列を単語単位に分割した配列で返す
  def words
    # self.delete("\r\n").scan(/[\w.\/:;'-]+/)

    pg = PragmaticTokenizer::Tokenizer.new(punctuation: :none)
    pg.tokenize(self)
  end

  def unique_words
    # words = []
    # sentences.map{|s|
    #   s.gsub(/^([A-Z])/) {|string| string.downcase }  # 行頭の大文字を小文字化（それ以外の大文字始まりを固有名詞としてスキップするため）
    #   words << s.scan(/[\s.!?:;'-]([a-z]{3,})[\s.!?:;'-]/)  # 「空白文字 + 小文字で3文字以上 + 空白文字」を単語として抽出
    # }
    # lem = Lemmatizer.new
    # words.flatten.uniq.map{|w| lem.lemma w}.uniq

    pt = PragmaticTokenizer::Tokenizer.new(
      filter_languges: [:en],
      punctuation: :none, # Removes all punctuation from the result.
      minimum_length: 3,
      downcase: true,
      clean: true, # Removes tokens consisting of only hypens, underscores, or periods as well as some special characters (®, ©, ™). Also removes long tokens or tokens with a backslash.
      numbers: :none, # Removes all tokens that include a number from the result (including Roman numerals)
      expand_contractions: true, # Expands contractions (i.e. i'll -> i will).
      long_word_split: 3, # The number of characters after which a token should be split at hypens or underscores.
      classic_filter: true, # Removes dots from acronyms and 's from the end of tokens.
    )
    lem = Lemmatizer.new
    pt.tokenize(self).uniq.map{|w| lem.lemma w}.uniq
  end

  # 文字列をセンテンス単位に分割した配列で返す
  def sentences
    ## 基本は「ピリオド or 感嘆符＋空白(改行)＋非空白文字」
    ## Mr.などの特殊例を除外: (ca. xx)などに対応するため、行頭or非文字or空白文字 + 特殊例 + ピリオド + 空白 + 非空白
    ## 名前などの略字を除外するため、1文字 + ピリオドの例も除外する（\wのところ）
    self.gsub(/(^|\W|\s)(Mr|Mrs|Ms|Mme|Sta|Sr|St|Sra|Dr|Jr|No|ca|U\.S\.A|\w)\.(?=\s+\S)/, '\1\2.[[TMP_SPACE]]')
        .gsub(/(^|\W|\s)(I|II|III|IV|V|VI|VII|VIII|IX|X|XI|XII|XIII|XIV|XV|XVI|XVII|XVIII|XIX|XX|\p{Nl}+)\.(?=\s+\S)/, '\1\2.[[TMP_SPACE]]') # ローマ数字も除外（アルファベットで表記してるのは手動除外）
        .gsub(/([\.\?\!]"?\)?\s+)(\S)/, '\1[[TMP]]\2') # セリフの終わりでも区切れるように、後ろが空白じゃなくて「"」とか「)」の場合も区切る（"?）
        .gsub("[[TMP_SPACE]]", "")
        .split("[[TMP]]")
  end
end
