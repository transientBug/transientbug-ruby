# In order to paginate both arrays, and sequel datasets, its nice to have a
# common interface in templates, so this provides a wrapper for that, allowing
# for custom pagination results for arrays, and proxying everything for sequel
# datasets.
class PagedPaginatedContainer
  include Enumerable

  attr_accessor :data, :pagination

  def initialize data, pagination: nil
    @data       = data
    @pagination = pagination
  end

  def each
    @data.each do |datum|
      yield datum
    end
  end

  def total
    return @data.pagination_record_count if @data.respond_to? :pagination_record_count

    @pagination[:total]
  end

  def first_page?
    return @data.first_page? if @data.respond_to? :first_page?

    @pagination[:first_page?]
  end

  def last_page?
    return @data.last_page? if @data.respond_to? :last_page?

    @pagination[:last_page?]
  end

  def current_page
    return @data.current_page if @data.respond_to? :current_page

    @pagination[:current_page]
  end

  def next_page
    return nil if last_page?

    current_page + 1
  end

  def previous_page
    return nil if first_page?

    current_page - 1
  end

  def per_page
    @pagination[:per_page]
  end
end

module Pagination
  extend ActiveSupport::Concern

  def paginate data
    return array_paginate data if data.kind_of? Array

    dataset_paginate data
  end

  private

  def dataset_paginate dataset
    page     = (params['page'].to_i if params['page'].present?) || 1
    per_page = (params['per_page'].to_i if params['per_page'].present?) || 24

    PagedPaginatedContainer.new dataset.paginate(page, per_page), pagination: {
      per_page: per_page
    }
  end

  def array_paginate array
    page            = (params['page'].to_i if params['page'].present?) || 1
    page           -= 1 # Because array indexing
    per_page        = (params['per_page'].to_i if params['per_page'].present?) || 24

    total           = array.length

    offset_start    = page * per_page
    offset_start    = 0 if offset_start < 0
    offset_end      = offset_start + per_page - 1 # Zero index, yo

    is_first_page   = offset_start <= 0
    is_last_page    = offset_end >= total

    paginated_array = array[offset_start..offset_end]

    PagedPaginatedContainer.new paginated_array, pagination: {
      first_page?:  is_first_page,
      last_page?:   is_last_page,
      current_page: page+1,
      total:        total,
      per_page:     per_page
    }
  end
end
