require 'fake_worker'

class RepositoryController < ApplicationController
  before_filter :init_status, :only => [:new, :show, :edit]
  before_filter :init_commit, :only => :update

  # display init page
  def new
  end

  # 1. svn revert
  # 2. svn update
  # 3. create Documents and Tags from svn repo
  def create
    FakeWorker.new(@pubsub_uri, @remote_user).update
  end

  # svn status
  def show
    render :json => titles_and_paths(@modified)
  end

  # display save page
  def edit
  end

  # 1. create html index
  # 2. svn commit
  def update
    FakeWorker.new(@pubsub_uri, @remote_user).commit(@options)
  end

  # svn revert --recursive
  def destroy
    render :json => titles_and_paths(Document.revert)
  end

  private

  def init_status
    @modified = Document.status
  end

  def init_commit
    @options = {
      :ip_address => request.remote_ip,
      :username   => $auth[@remote_user]['svn']['username'],
      :password   => $auth[@remote_user]['svn']['password']
    }
  end

  def titles_and_paths(documents)
    documents.map { |doc| [document_path(doc), doc.name] }
  end
end
