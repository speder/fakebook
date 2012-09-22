class TagsController < ApplicationController
  def index
    tags = Document.tags
    @tag_groups = Rails.cache.fetch("tags/#{tags.hash.abs}") {
        tags.sort.inject({}) { |hash, tag|
        hash[tag] = ((hash[tag] || []) + Document.tagged_with(tag)).sort_by(&:name)
        hash
      }.sort_by(&:first)
    }
  end

  def search
    tags = if params[:term].present?
             Document.tags.select { |tag| tag =~ /#{params[:term]}/i }
           else
             []
           end
    render :json => tags
  end
end
