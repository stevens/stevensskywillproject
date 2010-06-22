class PartnershipsController < ApplicationController

  before_filter :preload_models
#  before_filter :admin_protect
  before_filter :protect, :except => [:index, :show]

  def index
    load_partya

    @item_for_bar = @partya

    load_item_groups

    # show_sidebar

    partya_type = type_for(@partya)
    partya_name = name_for(partya_type)
    partya_title = item_title(@partya)
    partya_username = user_username(@partya.user, true, true)
    partnerships_link_url = "#{item_first_link(@partya)}/partnerships"

    info = "#{PARTNER_CN} - #{partya_title}"
    set_page_title(info)
    set_block_title(info)
    @meta_description = "这是#{partya_title}的#{partya_name}#{PARTNER_CN}信息, 来自#{partya_username}."
    set_meta_keywords
    @meta_keywords = [ partya_name, partya_title, partya_username, partnerships_link_url ] + @meta_keywords
    @meta_keywords << @partya.tag_list if !@partya.tag_list.blank?

    respond_to do |format|
      format.html
    end
  end

  private

  def preload_models()
    PartnershipCategory
    Partner
  end

  def set_meta_keywords
		@meta_keywords = [ PARTNER_CN ]
	end

  def load_partya
    if %w[ Election ].include?(@parent_type)
      @partya = @parent_obj
    end
  end

  def load_item_groups_cache_id
    @item_groups_cache_id = "#{type_for(@partya).tableize.singularize}_#{@partya.id}_partnerships_item_groups"
  end

  def load_item_groups
    load_item_groups_cache_id
    begin
      @item_groups = CACHE.get(@item_groups_cache_id)
    rescue Memcached::NotFound
      @item_groups = partnership_groups(@partya)
      CACHE.set(@item_groups_cache_id, @item_groups)
    end
  end

end
