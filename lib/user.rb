class User

  def initialize(db_name)
    @db_name   = db_name
    @user_name = ""
    @dbh = RDBI.connect(:SQLite3, :database => @db_name)

    # インスタンス変数の初期化
    @adventure    = Adventure.new(@dbh)
    @typing       = Typing.new(@dbh)
    @flag_manager = FlagManager.new
    @chapter_id   = 0
    @adventure_id = 0
    @typing_id    = 0
  end

  def disconnect_db
    @dbh.disconnect
  end


  # 初期化
  def start(user_name)

    @user_name = user_name

    # 既存user_nameチェック
    if name_exist? == true
      return  false
    end

    # スタートのインスタンス変数初期化
    @chapter_id   = 1
    @adventure_id = 1
    @typing_id    = 1
  end

  # dbから続きのデータをhashに格納
  def restart(user_name)

    @user_name = user_name

    # save_dataテーブルからデータを取り出し
    user_data = @dbh.execute("select                      "\
                             "user_name          ,        "\
                             "chapter_id         ,        "\
                             "adventure_id       ,        "\
                             "typing_id          ,        "\
                             "flag_namelist      ,        "\
                             "true_judge         ,        "\
                             "false_judge                 "\
                             "from                        "\
                             "save_data                   "\
                             "where                       "\
                             "user_name = '#{@user_name}';").first


    if user_data == nil
      puts " #{@user_name} というユーザー名は見つかりません"
      sleep(1)
      return
    end

    load_data = SaveDataInfo.new(user_data)

    # フラグテーブルのcsvをハッシュに格納
    @flag_manager.db_to_flag_hash(load_data.flag_namelist)

    # タイピング問題の正誤を値をtrue,falseにしてhashに格納
    @flag_manager.db_to_judge_hash(load_data.true_judge,
                                   load_data.false_judge)


    # 途中からのidを格納
    @chapter_id   = load_data.chapter_id
    @adventure_id = load_data.adventure_id
    @typing_id    = load_data.typing_id
  end

  # usernameがすでにあるか調べる
  def name_exist?
  exist_name = @dbh.execute("select           "\
                            "user_name        "\
                            "from             "\
                            "save_data        "\
                            "where            "\
                            "user_name =      "\
                            "'#{@user_name}' ;").first
    if exist_name != nil
      puts "その名前は使用されています"
      return true
    end
  end

  # 本体
  def run

    loop do

      puts "-------------Chapter #{@chapter_id}----------------------"

      # アドベンチャーを呼び出し、次のtyping_idとflag_idの値を格納する
      @typing_id, flag_id = @adventure.run(@chapter_id,
                                           @adventure_id,
                                           @flag_manager.flag_hash)

      # Ending判断
      if @typing_id == 0
        break
      end

      if @chapter_id.between?(2,4)
        # chapter_idとflag_idを使ってflag_hashに格納
        @flag_manager.flag_to_hash(@chapter_id,flag_id)
      end


      # タイピングを呼び出し、次のadventure_idとjudgeの値を格納する
      @adventure_id, judge = @typing.run(@chapter_id, @typing_id)

      # chpater_idとjudgeを使ってjudge_hashに格納
      @flag_manager.judge_to_hash(@chapter_id, judge)

      puts "Chapter #{@chapter_id}が終了しました"

      # 次のチャプターにインクリメント
      @chapter_id += 1

      # save判断
      puts "セーブしますか？"
      print "するなら y を入力: "
      save_char = gets.chomp.downcase

      if save_char == "y"
        # saveメソッド呼び出し
        save
      end

      puts "ゲームをやめますか？"
      print "やめるならyを入力 :"
      break_char = gets.chomp.downcase
      if break_char == "y"
        puts "終わります"
        break
      end
    end
    disconnect_db
  end

  def save
    # ハッシュを保存形式のcsvに変換する
    flag_namelist             = @flag_manager.to_flag_csv
    true_judge, false_judge   = @flag_manager.to_judge_csv

p flag_namelist # TODO
p true_judge# TODO
p false_judge# TODO
    # user_nameがすでに保存されているか調べる
    exist = @dbh.execute("select                      "\
                         "user_name                   "\
                         "from                        "\
                         "save_data                   "\
                         "where                       "\
                         "user_name = '#{@user_name}';").first

    # されてないならinsert
    if exist == nil

      save_db = @dbh.execute("insert into                "\
                             "save_data (                "\
                             "user_name               ,  "\
                             "chapter_id              ,  "\
                             "adventure_id            ,  "\
                             "typing_id               ,  "\
                             "flag_namelist           ,  "\
                             "true_judge              ,  "\
                             "false_judge              ) "\
                             "values (                   "\
                             "'#{@user_name}'         ,  "\
                             " #{@chapter_id}         ,  "\
                             " #{@adventure_id}       ,  "\
                             " #{@typing_id}          ,  "\
                             "'#{flag_namelist}'      ,  "\
                             "'#{true_judge}'  ,         "\
                             "'#{false_judge}'  )       ;")

      puts "#{@user_name} のセーブが完了しました\n"

    # されているならupdate
    else
      update_db = @dbh.execute("update                                         "\
                               "save_data                                      "\
                               "set                                            "\
                               "chapter_id          =  #{@chapter_id}         ,"\
                               "adventure_id        =  #{@adventure_id}       ,"\
                               "typing_id           =  #{@typing_id}          ,"\
                               "flag_namelist       = '#{flag_namelist}'      ,"\
                               "true_judge          = '#{true_judge}'         ,"\
                               "false_judge         = '#{false_judge}'         "\
                               "where                                          "\
                               "user_name           = '#{@user_name}'         ;")
      puts "#{@user_name} のセーブが完了しました\n"
    end
  end
end
