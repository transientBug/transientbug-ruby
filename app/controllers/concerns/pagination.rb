module Pagination
  extend ActiveSupport::Concern

  included do
  end

  def before_after_paginate array
    total = array.length

    per_page = params['per_page'] || 18
    per_page -= 1 # Array end offset

    begin
      if params['after']
        range_start = array.index(params['after']) + 1
        range_end   = range_start + per_page
      elsif params['before']
        range_end   = array.index(params['before']) - 1
        range_start = range_end - per_page
      else
        range_start = 0
        range_end   = per_page
      end
    rescue
      range_start   = 0
      range_end     = per_page
    end

    paginated_array   = array[range_start..range_end]

    pagination_before = if range_start <= 0
                          nil
                        else
                          paginated_array.first
                        end

    pagination_after  = if range_end >= total
                          nil
                        else
                          paginated_array.last
                        end

    pagination = {
      per_page: per_page,
      before:   pagination_before,
      after:    pagination_after,
      total:    total
    }

    [ paginated_array, pagination ]
  end
end
