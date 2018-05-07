require 'rdbi'
require 'rdbi-driver-sqlite3'
require './lib/adventure.rb'
require './lib/flag_manager.rb'
require './lib/typing.rb'
require './lib/user.rb'
require './lib/save_data_info.rb'

# dbの名前指定
db_name = "missionx.db"

# userクラス初期化
user = User.new(db_name)



print "\x1b[2J\x1b[0;0H"
puts "MissionX"
puts "1    : start\n2    : restart\nOther: exit"
print "Number: "
num = gets.to_i






case num
when 1
  begin
    puts "'は使わないでください"
    print "ユーザー名を入力してください: "
    user_name = gets.chomp
  end while user_name.match(/'/)
  new_name = user.start(user_name)
  if new_name != false
    user.run
  end
  puts "\n\n終わります"
  user.disconnect_db
when 2
  begin
    puts "'は使わないでください"
    print "ユーザー名を入力してください: "
    user_name = gets.chomp
  end while user_name.match(/'/)
  user.restart(user_name)
  user.run
  puts "\n\n終わります"
  user.disconnect_db
else
  puts "\n\nSee ya"
  user.disconnect_db
end




