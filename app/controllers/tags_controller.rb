class TagsController < ApplicationController
  def index
    @tag_groups = Document.tags.sort.inject({}) { |hash, tag| 
      hash[tag] = ((hash[tag] || []) + Document.tagged_with(tag)).sort_by(&:name)
      hash
    }.sort_by(&:first)
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
