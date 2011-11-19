require 'mongoid/document/taggable'

class Document
  include Mongoid::Document
  include Mongoid::Document::Taggable

  cattr_accessor :repository, :local_path, :username, :password
  @@repository = '%s/fakebook' % APP_CONFIG['svn']['url']
  @@local_path = '%s/fakebook' % APP_CONFIG['svn']['local_path']
  @@username = '--username %s' % APP_CONFIG['svn']['username']
  @@password = '--password %s' % APP_CONFIG['svn']['password']

  field :name, :type => String
  field :size, :type => Integer
  field :date, :type => Time
  field :author, :type => String
  field :revision, :type => Integer

  scope :alphabetical, order_by(:name, :asc)
  scope :new_or_changed_since, ->(date) { where(:date.gte => date).order_by(:date, :desc) }
  scope :named, ->(name) { where(:name => name) }

  def set_tags(tags=nil)
    if tags.present?
      self.tag_list = Array(tags).map(&:titleize).uniq.join(', ')
    else
      self.tags = nil
    end
  end

  def get_tags_from_repo!
    if name =~ /'/
      %x(svn propget tags --strict #{local_path}/"#{name}")
    else
      %x(svn propget tags --strict #{local_path}/'#{name}')
    end
  end 

  def set_tags_from_repo!
    tag_props = get_tags_from_repo!
    set_tags(eval(tag_props))
    save!
  end 

  def set_tags_in_repo!
    if tags.present?
      # "John Lennon, Paul Mccartney" --> "[\"john lennon\",\"paul mccartney\"]"
      tag_props = '"[%s]"' % tag_list.downcase.split(',').map{ |t| '\"%s\"' % t.strip }.join(',')
      if name =~ /'/
        %x(svn propset tags #{tag_props} #{local_path}/"#{name}")
      else
        %x(svn propset tags #{tag_props} #{local_path}/'#{name}')
      end
    else
      if name =~ /'/
        %x(svn propdel tags #{local_path}/"#{name}")
      else
        %x(svn propdel tags #{local_path}/'#{name}')
      end
    end 
  end 

  def self.search(term)
    where(:name => /#{term}/i).order_by(:name, :asc)
  end

  def self.get_from_repo!
    %x(svn list #{repository} --xml #{username} #{password})
  end

  def self.create_from_repo!(verbose = true)
    puts "Creating documents from #{repository}" if verbose
    delete_all
    entity = HTMLEntities.new
    count = 0 
    xml = get_from_repo!
    (Hpricot.XML(xml)/:list/:entry).each do |e| 
      next if entity.decode((e/:name).inner_html) =~ /^\./
        create!(
          :name => entity.decode((e/:name).inner_html), 
          :size => (e/:size).inner_html, 
          :date => DateTime.parse((e/:date).inner_html),
          :author => (e/:author).inner_html,
          :revision => (e % :commit)[:revision]
      )   
      count += 1
      (print "#{count}\r"; $stdout.flush) if verbose
    end 
    puts "#{count} #{self}s loaded" if verbose
    count
  end 

  def self.get_tags_from_repo!
    %x(svn propget tags #{repository} -R #{username} #{password})
  end

  def self.add_tags_from_repo!(verbose = true)
    puts "Adding tags from #{repository}" if verbose
    count = 0
    get_tags_from_repo!.split("\n").each do |line|
      next if line.blank?
      name, tags = line.match(/(.*)\/(.*) \- (\[.*\])/)[2..3]
      tags = eval(tags)
      where(:name => name).each do |doc|
        doc.set_tags(tags)
        doc.save!
        count += 1
        (print "#{count}\r"; $stdout.flush) if verbose
      end
    end
    puts "#{count} tags added" if verbose
    count
  end

  def self.without_tags
    order_by(:name, :asc).select{|d| d.tags.blank? }
  end
end
