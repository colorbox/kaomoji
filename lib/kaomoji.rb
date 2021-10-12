require 'kaomoji/version'
require 'unicode/x'

module Kaomoji
  class << self
    def kaomoji_parts?(chr)
      kaomoji_group_categories = %w(Pc Pd Pe Pf Pi Po Ps Sc Sk Sm So)
      japanese_group = %w(Basic\ Latin Hiragana CJK\ Unified\ Ideographs Fullwidth\ ASCII\ Variants)
      return !japanese_group.include?(::Unicode::Blocks.blocks(chr).first) || kaomoji_group_categories.include?(::Unicode::Categories.categories(chr).first)
    end

    def normal_char?(chr)
      normal_char_blocks = %w(Lc Ll Lm Lo Lt Lu Nd Nl)
      target_block = ::Unicode::Categories.categories(chr)
      normal_char_blocks.include?(target_block.first)
    end

    def get_kaomojis(str)
      return [] if str.chars.length.zero?

      kaomojis = (0..str.chars.size-1).map{|i| get_one_unicode_kaomoji_at_index(i, str) if kaomoji_parts?(str.chars[i]) }.uniq.compact
      kaomojis.select{|k|valid_kaomoji?(k)}.reject {|target| kaomojis.map {|kaomoji| (kaomoji!=target) && kaomoji.include?(target) }.any? }
    end

    def get_one_unicode_kaomoji_at_index(index, str)
      start = get_kaomoji_left_side(index, str)
      last = get_kaomoji_right_side(index, str)
      str.chars[start..last].join
    end

    THRESHOLD=2

    def get_kaomoji_right_side(start_index, str)
      return start_index if start_index==str.chars.length-1
      last = start_index
      count = 0
      str.chars[start_index..str.length-1].each_with_index do |chr, index|
        if kaomoji_parts?(chr)
          count = 0
          last = start_index + index
        elsif normal_char?(chr)
          count += 1
        end
        return last if count > THRESHOLD || index == str.chars[start_index..str.length-1].length - 1
      end
    end

    def get_kaomoji_left_side(start_index, str)
      return 0 if start_index.zero?
      first = start_index
      count = 0
      str.chars[0..start_index].reverse.each_with_index do |chr, index|
        if kaomoji_parts?(chr)
          count = 0
          first = start_index - index
        elsif normal_char?(chr)
          count += 1
        end
        return first if count > THRESHOLD || index == start_index-1
      end
    end

    def unicode_kaomojis(threshold = 2, str)
      kaomojis = []
      current=[]
      count=0
      str.split('').each do |chr|
        if kaomoji_parts?(chr)
          current.push(chr)
          count=0
        else
          count+=1
        end

        pp [chr,count]
        if count > threshold
          kaomoji = current.join
          kaomojis.push(kaomoji) if valid_kaomoji?(kaomoji)
          current=[]
          count=0
        end
      end

      if current.count > 0
        kaomoji = current.join
        kaomojis.push(kaomoji) if valid_kaomoji?(kaomoji)
      end

      kaomojis
    end

    def valid_kaomoji?(kaomoji)
      kaomoji.length > 3 && !half_of_normal_chars(kaomoji)
    end

    def half_of_normal_chars(str)
      normal_chars = %w(Lc Ll Lm Lo Lt Lu Nd Nl)
      normal_words_count =str.split('').map{|chr|::Unicode::Categories.categories(chr).map{|block|normal_chars.include?(block)}.any? ? 1 : 0}.sum.to_f
      all_count = str.length.to_f
      result = (normal_words_count / all_count) > 0.5
      result
    end
  end
end
