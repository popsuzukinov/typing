class FlagManager
  def initialize
    @flag_hash  = {}
    @judge_hash = {}
  end
  attr_accessor :flag_hash, :judge_hash

  # フラグ結果をハッシュに格納
  def flag_to_hash(chapter_id,flag_id)
    self.flag_hash.store(chapter_id,flag_id)
  end
  # 問題の正誤結果をハッシュに格納
  def judge_to_hash(chapter_id,judge)
    self.judge_hash.store(chapter_id,judge)
  end

  # sqlite3に格納時、csvに変換
  def to_flag_csv
    flag_namelist  = ""
    self.flag_hash.each do |key,val|
      flag_namelist  << "#{val}" + ","
    end
    return flag_namelist
  end

  def to_judge_csv
    true_judge  = ""
    false_judge = ""
    self.judge_hash.each do |key,val|
      if    val == true
        true_judge  << "#{key.to_i}" + ","
      elsif val == false
        false_judge << "#{key.to_i}" + ","
      end
    end
    return true_judge,false_judge
  end

  # dbに格納されたcsvを配列に変換し、@flag_hashに格納
  def db_to_flag_hash(flag_namelist)

    flag_array = flag_namelist.split(",")
    chapter_id = 2
    flag_array.each do |flag_id|
      self.flag_hash.store(chapter_id,flag_id.to_i)
      chapter_id += 1
    end
  end

  # dbに格納されたcsvを配列に変換し、@typing_judge_hashに格納
  def db_to_judge_hash(true_judge,false_judge)

    true_array = true_judge.split(",")
    true_array.each do |val|
      self.judge_hash.store(val.to_i,true)
    end

    false_array = false_judge.split(",")
    false_array.each do |val|
      self.judge_hash.store(val.to_i,false)
    end
  end
end
