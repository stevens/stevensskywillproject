module MenusHelper

  def menus_for(user = nil, menu_conditions = nil, limit = nil, order = 'created_at DESC, published_at DESC')
		if user
      if !menu_conditions.blank?
        user.menus.find(:all, :limit => limit, :order => order,
                        :conditions => menu_conditions)
      else
        user.menus.find(:all, :limit => limit, :order => order)
      end
		else
      if !menu_conditions.blank?
        Menu.find(:all, :limit => limit, :order => order,
                  :conditions => menu_conditions)
      else
        Menu.find(:all, :limit => limit, :order => order)
      end
		end
	end

#  def menu_conditions(user = nil)
#    conditions = ["menus.title IS NOT NULL",
#  								"menus.title <> ''",
#                  "menus.meal_duration IS NOT NULL",
#                  "menus.meal_kind IS NOT NULL",
#                  "menus.meal_system IS NOT NULL",
#  								"menus.description IS NOT NULL",
#  								"menus.description <> ''",
#  								"menus.from_type IS NOT NULL",
#  								"menus.privacy IS NOT NULL"]
#  end

end
