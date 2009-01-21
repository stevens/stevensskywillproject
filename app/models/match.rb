class Match < ActiveRecord::Base
	include ApplicationHelper
	
	acts_as_taggable
	
	belongs_to :user
	belongs_to :organiger, :polymorphic => true
	
	has_one :counter, :dependent => :destroy, :as => :countable, :foreign_key => :countable_id
	
	has_many :photos, :dependent => :destroy, :as => :photoable, :foreign_key => :photoable_id, :order => "created_at"
	has_many :reviews, :dependent => :destroy, :as => :reviewable, :foreign_key => :reviewable_id, :order => "created_at DESC"
	has_many :favorites, :dependent => :destroy, :as => :favorable, :foreign_key => :favorable_id, :order => "created_at DESC"
	has_many :entries, :order => "created_at DESC"
	has_many :awards, :order => "level, created_at"
	has_many :votes, :dependent => :destroy, :as => :votein, :foreign_key => :votein_id, :order => "created_at DESC"
	has_many :winners, :order => "created_at"
	has_many :match_actors, :order => "created_at DESC"
 	has_many :players, 
  				 :class_name => "MatchActor", 
  				 :conditions => "roles = 1", 
  				 :dependent => :destroy, 
  				 :order => "created_at DESC"
 	has_many :admins, 
  				 :class_name => "MatchActor", 
  				 :conditions => "roles = 2", 
  				 :dependent => :destroy, 
  				 :order => "created_at DESC"
	
	def accessible?(someuser = nil)
		true
	end
	
	#判断比赛是否处于某个状态
	def is_status_of?(status_name)
		if status
			status_code = Code.find_by_codeable_type_and_name('match_status', status_name).code
			status == status_code ? true : false
		else
			false
		end
	end
	
	#获得比赛整体的时间状态参数
	def match_time_status(current)
		time_status(current, start_at, end_at)
	end
	
	#获得比赛报名的时间状态参数
	def enroll_time_status(current)
		if enrolling_start_at
			s = enrolling_start_at
		elsif start_at
			s = start_at
		end
		if enrolling_end_at
			e = enrolling_end_at
		elsif end_at
			e = end_at
		end
		time_status(current, s, e)
	end
	
	#获得比赛征集的时间状态参数
	def collect_time_status(current)
		if collecting_start_at
			s = collecting_start_at
		elsif start_at
			s = start_at
		end
		if collecting_end_at
			e = collecting_end_at
		elsif end_at
			e = end_at
		end
		time_status(current, s, e)
	end
	
	#获得比赛投票的时间状态参数
	def vote_time_status(current)
		if voting_start_at
			s = voting_start_at
		elsif start_at
			s = start_at
		end
		if voting_end_at
			e = voting_end_at
		elsif end_at
			e = end_at
		end
		time_status(current, s, e)
	end
	
	#判断比赛是否未开始
	def todo?
		status == '10' ? true : false
	end
	
	#判断比赛是否进行中
	def doing?(current)
		(status == '20' && match_time_status(current)[1] == 'doing') ? true : false
	end
	
	#判断比赛是否已结束
	def done?
		status == '30' ? true : false
	end
	
	#查找比赛的某个选手
	def find_actor(user, actor_role)
		match_actors.find_by_user_id_and_roles(user.id, actor_role) 
	end
	
	#查找比赛的某个参赛作品
	def find_entry(entriable)
		entries.find_by_entriable_type_and_entriable_id(type_for(entriable), entriable.id)
	end
	
	#查找某个投票者为某个参赛作品投的票
	def find_vote(user, voteable)
		votes.find_by_user_id_and_voteable_type_and_voteable_id(user.id, type_for(voteable), voteable.id)
	end
	
	#判断某个参赛选手是否有参赛作品
	def player_has_entries?(user)
		entries.find(:first, :conditions => { :user_id => user.id })
	end
	
	#查找某个参赛选手的参赛作品
	def find_player_entries(user)
		entries.find(:all, :conditions => { :user_id => user.id })
	end
	
	#判断某个投票者是否已为参赛作品投过票
	def voter_has_entries?(user)
		votes.find(:first, :conditions => { :user_id => user.id })
	end
	
	#查找某个投票者已投过票的参赛作品
	def find_voter_entries(user)
		votes.find(:all, :conditions => { :user_id => user.id })
	end
	
	#计算某个参赛选手可以提交的剩余参赛作品数量
	def player_remain_entries_count(user)
		if epp = entries_per_player
			submitted_count = find_player_entries(user).size
			epp - submitted_count
		end
	end
	
	#计算某个投票者可以投票的剩余参赛作品数量
	def voter_remain_entries_count(user)
		if epv = entries_per_voter
			voted_count = find_voter_entries(user).size
			epv - voted_count
		end
	end
end
