class DocumentsController < ApplicationController
  def index
    date = 6.weeks.ago.to_date
    @document_groups = {
      'unidentified' => Document.without_tags,
      "new or different since #{date.to_s(:mdy)}" => Document.new_or_changed_since(date)
    }
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
    tags = params[:document][:tags] rescue nil
    @document.update_tags(tags)
    respond_to do |format|
      format.html {
        flash[:notice] = "tags = [ #{@document.tag_list} ] "
        render :show
      }
      format.js {
        render :json => { :name => @document.name, :tags => @document.tag_list }
      }
    end
  end
end
