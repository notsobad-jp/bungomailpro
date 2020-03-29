class String
  # 文字列を単語単位に分割した配列で返す
  def words
    self.delete("\r\n").scan(/[\w.\/:;'-]+/)
  end

  # 文字列をセンテンス単位に分割した配列で返す
  def sentences
    ## 基本は「ピリオド or 感嘆符＋空白(改行)＋非空白文字」
    ## Mr.などの特殊例を除外: (ca. xx)などに対応するため、行頭or非文字or空白文字 + 特殊例 + ピリオド + 空白 + 非空白
    ## 名前などの略字を除外するため、1文字 + ピリオドの例も除外する（\wのところ）
    self.gsub(/(^|\W|\s)(Mr|Mrs|Ms|Mme|Sta|Sr|St|Sra|Dr|Jr|No|ca|U\.S\.A|\w)\.(?=\s+\S)/, '\1\2.[[TMP_SPACE]]')
        .gsub(/([\.\?\!]"?\)?\s+)(\S)/, '\1[[TMP]]\2') # セリフの終わりでも区切れるように、後ろが空白じゃなくて「"」とか「)」の場合も区切る（"?）
        .gsub("[[TMP_SPACE]]", "")
        .split("[[TMP]]")
  end
end
