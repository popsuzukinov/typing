class SaveDataInfo
  def initialize(array)
    @user_name     = array[0]
    @chapter_id    = array[1]
    @adventure_id  = array[2]
    @typing_id     = array[3]
    @flag_namelist = array[4]
    @true_judge    = array[5]
    @false_judge   = array[6]
  end
  attr_accessor :user_name, :chapter_id, :adventure_id, :typing_id,
                :flag_namelist, :true_judge , :false_judge

end

