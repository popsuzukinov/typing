class Adventure
  def initialize(dbh)
    @dbh = dbh
  end

  # Enter押したら次の処理をする
  def move_text
    puts "\n-----------------------------"
    puts "進むにはEnterを押してください"
    i = gets
  end

  # 入力メソッド
  def input
    begin
      print "\n数字を入力してください: "
      num = gets.to_i
    end while num == 0
    return num
  end

  def run(chapter_id,adventure_id,flag_hash)

    # 初期化
    @chapter_id     = chapter_id
    @first_harf_id  = adventure_id
    @last_harf_id   = 2
    @flag_hash      = flag_hash      # {}形式
    @next_typing_id = 0              # returnするtyping_id


    # Chapter_idを参照し、ルート選択
    if    @chapter_id == 1
      tutorial
    elsif @chapter_id.between?(2,4)
      common_root
    elsif @chapter_id.between?(5,7)
      branch_root
    elsif @chapter_id == 8
      special_root
    end

    return @next_typing_id, @flag_hash[@chapter_id]
  end

  # チュートリアル
  def tutorial
    text_display(@chapter_id,@first_harf_id)
    @next_typing_id = 1
  end

  # 共通ルート
  def common_root
    # 前半のテキスト表示
    text_display(@chapter_id,@first_harf_id)

    # 選択肢入力
    result  = input
    # 選択したflagをハッシュに格納
    case result
    when 1
      flag_id = 1
      @flag_hash.store(@chapter_id,flag_id)
      flag_judge_id = 3
    when 2
      flag_id = 2
      @flag_hash.store(@chapter_id,flag_id)
      flag_judge_id = 4
    when 3
      flag_id = 3
      @flag_hash.store(@chapter_id,flag_id)
      if @chapter_id == 3
        flag_judge_id = 5
      end
    end

    # flag選択後のテキスト表示
    text_display(@chapter_id,flag_judge_id)
    move_text


    # 後半のテキスト表示
    text_display(@chapter_id,@last_harf_id)
    move_text


    # 次のタイピングID指定
    @next_typing_id = 1
  end

  # 個別ルート
  def branch_root

    # 前半のテキスト表示
    text_display(@chapter_id,@first_harf_id)

    # adventure_idが3or5ならtyping_idに0を入れて終了
    if @first_harf_id == 3 ||
       @first_harf_id == 6
      @next_typing_id = 0
      return
    end


    # flag_hashの値を合計する
    max     = @flag_hash.length
    max     += 2
    sum_num = 0

    2.upto(max) do |num|
      flag_num = @flag_hash[num]
      sum_num += flag_num.to_i
    end

    # 合計値で条件判断
    if    sum_num == 3 #全てのフラグが立っている
      @last_harf_id   = 2
      @next_typing_id = 1
    else
      @last_harf_id   = 4
      @next_typing_id = 2
    end

    # chapter6の例外を処理
    # 6-4なら終了
    if @chapter_id   == 6 &&
       @last_harf_id == 4
      @next_typing_id = 0
    end

    # chapter7の例外を処理

    # 7-1なら7-2を表示
    if    @chapter_id    == 7 &&
          @first_harf_id == 1
      @last_harf_id   = 2
      @next_typing_id = 1

    # 7-4なら終了
    elsif @chapter_id    == 7 &&
          @first_harf_id == 4
      @next_typing_id = 0
      return
    end

    # 後半のテキスト表示
    text_display(@chapter_id,@last_harf_id)
    move_text
  end

  # TRUEエンド
  def special_root

    # flag_hashの値を合計する
    max     = @flag_hash.length
    max     += 2
    sum_num = 0

    2.upto(max) do |num|
      flag_num = @flag_hash[num]
      sum_num += flag_num.to_i
    end

    # 合計値で条件判断
    if    sum_num == 3 #全てのフラグが立っている
      @first_harf_id  = 1
      @next_typing_id = 0
    else
      @first_harf_id  = 2
      @next_typing_id = 0
    end

    text_display(@chapter_id,@first_harf_id)
    move_text
  end


  # テキスト表示メソッド
  def text_display(chapter_id,adventure_id)
    value = @dbh.execute("select                           "\
                         "value                            "\
                         "from                             "\
                         "adventure                        "\
                         "where                            "\
                         "chapter_id   = #{chapter_id} and "\
                         "adventure_id = #{adventure_id}  ;").first

    print "\x1b[2J\x1b[0;0H"
    # 一文字ずつ表示
    value[0].each_char do |char|
      print "#{char}"
      sleep(0.05)
    end
    puts ""
  end
end
