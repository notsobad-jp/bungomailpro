require 'rails_helper'

RSpec.describe AozoraBook, type: :model do
  describe "sort_variant_books" do
    context "when different character_type" do
      it "should order by character_type" do
        variants = [
          {"access_count" => 800, "character_type" => "旧字旧仮名"},
          {"access_count" => 400, "character_type" => "旧字新仮名"},
          {"access_count" => 300, "character_type" => "新字新仮名"},
          {"access_count" => 500, "character_type" => "新字旧仮名"},
        ]
        res = variants.sort_by{ |variant| [%w(新字新仮名 新字旧仮名 旧字新仮名 旧字旧仮名).index(variant["character_type"]), -variant["access_count"]] }
        expect(res.pluck("character_type")).to eq %w(新字新仮名 新字旧仮名 旧字新仮名 旧字旧仮名)
      end
    end

    context "when same character_type" do
      it "should order by access_count" do
        variants = [
          {"access_count" => 800, "character_type" => "旧字旧仮名"},
          {"access_count" => 400, "character_type" => "新字新仮名"},
          {"access_count" => 300, "character_type" => "新字新仮名"},
          {"access_count" => 500, "character_type" => "旧字旧仮名"},
        ]
        res = variants.sort_by{ |variant| [%w(新字新仮名 新字旧仮名 旧字新仮名 旧字旧仮名).index(variant["character_type"]), -variant["access_count"]] }
        expect(res.pluck("access_count")).to eq [400, 300, 800, 500]
      end
    end
  end
end
