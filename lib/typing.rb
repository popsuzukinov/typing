class Typing

  def initialize(dbh)
    @dbh = dbh

  end
  def run(chapter_id,typing_id)
    @chapter_id = chapter_id
    @typing_id  = typing_id

    print "\x1b[2J\x1b[0;0H"
    # タイピング問題表示
    display(@chapter_id,@typing_id)

    # 解答をanswerに格納
    answer_array = input

    # answerを判断し、typing_judgeにture or faulsを格納
    judge = value_judge(chapter_id,typing_id,answer_array)

    # 次のadventure_idを判断する
    next_adventure_id = adventure_judge(judge)


    return next_adventure_id, judge
  end

  # 問題出力
  def display(chapter_id,typing_id)
    # 問題をdbから取り出す
    array = @dbh.execute("select                         "\
                         "value                          "\
                         "from typing                    "\
                         "where                          "\
                         "chapter_id = #{chapter_id} and "\
                         "typing_id  = #{typing_id} ;    ").first

    question_array = array[0]

    # TODO 仮の出力
      puts "\n以下を入力せよ-------------------------------------------------------"
      puts "#{question_array}"
      puts "---------------------------------------------------------------------"

  end

  # 解答入力
  def input
    # @answerの初期化
    input_val = []
    print "入力終了した場合\n.quitを入力してください\n "
    loop do
      val = gets.chomp
      if val == ".quit"
        return input_val
      end
      input_val << val
    end
  end



  # 正誤判断 @judgeに格納してください
  def value_judge(chapter_id,typing_id,answer_array)

    if answer_array.empty?
      puts "不正解"
      return false
    end

    # 問題をdbから取り出す
    array = @dbh.execute("select                         "\
                         "value                          "\
                         "from typing                    "\
                         "where                          "\
                         "chapter_id = #{chapter_id} and "\
                         "typing_id  = #{typing_id}     ;").first

    question_array = array[0].split("\n")

    if question_array.length != answer_array.length
      puts "不正解"
      return false
    end

    question_array.length.times do |num|
      if question_array[num] != answer_array[num]
        puts "不正解"
        puts "-------------------------------------------------------------"
        puts "#{question_array[num]}\n\n----答え\n#{answer_array[num]}\n\n-------入力"
        puts "-------------------------------------------------------------"
        return false
      end
    end

    puts "正解"
    return true
  end

  def adventure_judge(judge)

    if @chapter_id.between?(1,2)
      next_adventure_id = 1
      return next_adventure_id
    end

    if @chapter_id == 3
      if    judge == true
        next_adventure_id = 1
      elsif judge == false
        next_adventure_id = 5
      end
      return next_adventure_id
    end

    case @typing_id
    when 1
      if    judge == true
        next_adventure_id = 1
      elsif judge == false
        next_adventure_id = 3
      end
    when 2
      if    judge == true
        next_adventure_id = 5
      elsif judge == false
        next_adventure_id = 6
        if @chapter_id == 5
          next_adventure_id = 3
        end
      end
    end

    return next_adventure_id
  end
end

