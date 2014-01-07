require 'mongoid/document/taggable'

class Document
  include Mongoid::Document
  include Mongoid::Document::Taggable

  field :name,     :type => String
  field :size,     :type => Integer
  field :date,     :type => Time
  field :author,   :type => String
  field :revision, :type => Integer

  attr_accessible :name, :size, :date, :author, :revision

# scope :alphabetical, order_by(:name, :asc)
  scope :alphabetical, asc(:name)
  scope :new_or_changed_since, ->(date) {
#   where(:date.gte => date).order_by(:name, :asc)
    where(:date.gte => date).asc(:name)
  }
  scope :named, ->(name) { where(:name => name) }

  # 1. update Document tags from UI
  # 2. save Document tags to repo
  # 3. update Document tags from repo
  # 4. save Document
  def update_tags(tags = nil)
    set_tags(tags)
    write_tags_to_repo
    read_tags_from_repo
    save!
  end

  def set_tags(tags = nil)
    if tags.present?
      self.tag_list = Array(tags).map(&:titleize).uniq.join(', ')
    else
      self.tags = nil
    end
  end

  def write_tags_to_repo
    Repository.set_tags(self)
  end

  def read_tags_from_repo
    tag_props = Repository.get_tags(name)
    set_tags(eval(tag_props))
  end

  # ignore file extension in name
  def self.search(term)
    file_extension = /\..+$/
    contains_term  = /#{term}/i
#   where(:name => contains_term).order_by(:name, :asc).select{ |doc|
    where(:name => contains_term).asc(:name).select{ |doc|
      doc.name.gsub(file_extension, '') =~ contains_term
    }
  end

  def self.without_tags
#   order_by(:name, :asc).select{ |d| d.tags.blank? }
    asc(:name).select{ |d| d.tags.blank? }
  end

  # return mutating entries wrapped as Documents
  def self.status(options = {})
    Repository.status.split(/\n/).map { |line|
      # " M      /path/to/repository/Document Name.pdf\n"
      named(line.split(/\//).last).first
    }.sort_by(&:name)
  end

  # return reverted entries wrapped as Documents
  def self.revert
    Repository.revert.split(/\n/).map { |line|
      # "Reverted '/path/to/repository/Document Name.pdf'\n"
      named(line.split(/\//).last.gsub(/'$/, '')).first
    }
  end
end
