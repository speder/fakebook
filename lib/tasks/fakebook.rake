namespace :db do
  desc 'Create Docs and Tags'
  task :boot  => :environment do
    Document.create_from_repo!
    Document.add_tags_from_repo!
  end
end

namespace :html do
  desc 'Rebuild HTML index'
  task :index => :environment do
    require 'erb'
    tag_groups = Document.tags.inject({}) { |hash, tag| hash[tag] = Document.tagged_with(tag); hash }
    doc_groups = Document.alphabetical.group_by { |doc| doc.name.upcase[0..0] }
    @groups = doc_groups.merge(tag_groups)
    @untagged = Document.without_tags
    @recent = Document.new_or_changed_since(@recent_date = 8.weeks.ago)
    template = File.expand_path(File.join(Rails.root, 'public/repo/index.html.erb'))
    html = ERB.new(open(template, 'r') { |f| f.read })
    output = File.expand_path(File.join(Document.local_path, '.fakebook.html'))
    open(output, 'w') { |f| f.write(html.result) }
    puts "rebuilt HTML index in #{output}"
  end
end
=begin
namespace :s3 do
  desc 'Upload zip of docs to s3'
  task :upload => :zip do
    require 'aws/s3'
    AWS::S3::Base.establish_connection!(
      :access_key_id     => APP_CONFIG['s3']['access_key_id'],
      :secret_access_key => APP_CONFIG['s3']['secret_access_key']
    )
    key = APP_CONFIG['s3']['key']
    bucket = APP_CONFIG['s3']['bucket']
    zip = "tmp/#{key}"
    puts "uploading to #{bucket}"
    AWS::S3::S3Object.store(
      key, 
      open(zip), 
      bucket, 
      :access => :public_read
    )
    puts "https://s3.amazonaws.com/#{bucket}/#{key}"
  end

  task :zip => :environment do
    require 'zip/zip'
    key = APP_CONFIG['s3']['key']
    path = "tmp/#{key}"
    File.delete(path) if File.exists?(path)
    puts "compressing .doc files in #{Document.local_path}"
    count = 0
    Zip::ZipFile.open(path, Zip::ZipFile::CREATE) do |zip|
      Dir.glob("#{Document.local_path}/*.doc").each do |doc|
        zip.add(doc.gsub(/.*\//, ''), doc)
        count += 1
      end
      zip.add('index.html', "#{Document.local_path}/.fakebook.html")
    end
    puts "compressed %s files into %s" % [count, Bytes.file(path)]
  end
end
=end
namespace :tags do
  desc 'Read tags from svn repo for doc=...'
  task :get => :environment do
    docs = ENV['doc'] ? Document.named(ENV['doc']) : Document.all
    docs.each do |doc|
      if (tags = doc.get_tags_from_repo!).present?
        puts "#{doc.name} - #{tags}"
      else
        puts doc.name
      end
    end
  end
  
  desc 'Set tags in svn repo for doc=... tags="...,..."'
  task :set => :environment do
    unless ENV['doc'] and ENV['tags']
      puts %Q(usage: rake tags:set doc="Bali Hai.doc" tags="richard rodgers, lorenz hart") 
      exit
    end
    
    if (doc = Document.named(ENV['doc']).first)
      puts 'setting %s - %s' % [ doc.name, ENV['tags'] ]
      doc.set_tags(ENV['tags'])
      doc.set_tags_in_repo!
      doc.set_tags_from_repo!
    else
      puts "cannot find #{ENV['doc']}"
    end
  end

  desc 'Docs without tags'
  task :none => :environment do
    Document.without_tags.each { |doc| puts doc.name }
  end
  
  desc 'Read all tags from svn repo'
  task :all => :environment do
    Document.get_tags_from_repo!.split("\n").sort.each do |line|
      next if line.blank?
      puts "%s - %s" % line.match(/(.*)\/(.*) \- (\[.*\])/)[2..3]
    end
  end
end

namespace :repo do
  desc 'Stat local svn repo'
  task :status => :environment do
    puts %x(svn status #{File.expand_path(Document.local_path)})
  end
  
  desc 'Update local svn repo'
  task :update => :environment do
    puts %x(svn update #{File.expand_path(Document.local_path)})
  end
  
  desc 'Commit local svn repo'
  task :commit => :environment do
    puts %x(svn commit -m '' #{File.expand_path(Document.local_path)})
  end
  
  desc 'Revert local svn repo'
  task :revert => :environment do
    puts %x(svn revert -R #{File.expand_path(Document.local_path)})
  end
end

class Bytes
  K = 2.0**10
  M = 2.0**20
  G = 2.0**30
  T = 2.0**40
  def self.file(path)
    format(File.size(path))
  end
  def self.format(bytes, max_digits=3)
    bytes = bytes.to_i
    value, suffix, precision = case bytes
      when 0...K
        [ bytes, 'b', 0 ]
      else
        value, suffix = case bytes
          when K...M then [ bytes / K, ' kb' ]
          when M...G then [ bytes / M, ' mb' ]
          when G...T then [ bytes / G, ' gb' ]
          else            [ bytes / T, ' tb' ]
        end
        used_digits = case value
          when   0...10   then 1
          when  10...100  then 2
          when 100...1024 then 3
        end
        leftover_digits = max_digits - used_digits
        [ value, suffix, leftover_digits > 0 ? leftover_digits : 0 ]
    end
    "%.#{precision}f#{suffix}" % value
  end
end
