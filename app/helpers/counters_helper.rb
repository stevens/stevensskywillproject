module CountersHelper

	def views_count(item)
		if counter = item.counter
			tvc = counter.total_view_count || 0
			svc = counter.self_view_count || 0
		else
			tvc = 0
			svc = 0
		end
		tvc - svc
	end

end
