class String
  # 文字列を単語単位に分割した配列で返す
  def words
    self.delete("\r\n").scan(/[\w.\/:;'-]+/)
  end

  # 文字列をセンテンス単位に分割した配列で返す
  def sentences
    ## 基本は「ピリオド or 感嘆符＋空白(改行)＋非空白文字」
    ## Mr.などの特殊例を除外: (?<!)が否定の後読み
    ## セリフの終わりでも区切れるように、「."」も区切る: 「"?」の部分
    self.gsub(/(?<!Mr|Mrs|Ms|Mme|Sta|Sr|Sra|Dr|U\.S\.A)([\.\?\!]"?\s+)(\S)/, '\1[[TMP]]\2').split("[[TMP]]")
  end
end
