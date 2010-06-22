class JudgeCategory < ActiveRecord::Base

  belongs_to :judgein, :polymorphic => true

  has_many :judges, :order => "created_at DESC"

  def is_type_of?(name)
    if judge_type_code = Code.find(:first, :conditions => { :codeable_type => 'judge_type', :code => self.judge_type })
      judge_type_code_name = judge_type_code.name
    end
    (judge_type_code_name && judge_type_code_name == name) ? true : false
  end

end
