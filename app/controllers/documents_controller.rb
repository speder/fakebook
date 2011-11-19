class DocumentsController < ApplicationController
  def index
    @document_groups = { :untagged => Document.without_tags }
    @document_groups.merge!(Document.alphabetical.group_by { |doc| doc.name.upcase[0..0] })
  end

  def search
    documents = if params[:term].present?
                  Document.search(params[:term]).map{ |doc| { :value => doc.name, :id => doc.id } }
                else
                  []
                end
    render :json => documents
  end

  def show
    @document = Document.find(params[:id])
    @tag_groups = Document.tags.sort.group_by { |tag| tag.upcase[0..0] }
  end

  def update
    show
    if params[:document].present? && params[:document][:tags].present?
      tags = params[:document][:tags]
      flash.now[:notice] = "set #{@document.name} tags=#{tags.inspect}"
      @document.set_tags(tags)
    else
      flash.now[:notice] = "removed #{@document.name} tags"
      @document.set_tags
    end
    @document.set_tags_in_repo!
    @document.set_tags_from_repo!
    render :show
  end
end
