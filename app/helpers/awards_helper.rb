module AwardsHelper

  def award_basic_info(award)
		awardable_type = Code.find_by_codeable_type_and_name('awardable_type', award.awardable_type).title
		quota = (award.quota.blank? ? '名额待定' : "#{award.quota}名")
		decide_mode = Code.find_by_codeable_type_and_code('award_decide_mode', award.decide_mode).title
    "#{awardable_type} · #{quota} · #{decide_mode}"
  end
end
