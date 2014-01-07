namespace :db do
  desc 'Create DelayedJob Indexes'
  task :indexes => :environment do
    Delayed::Backend::Mongoid::Job.create_indexes
  end

  desc 'Create Docs and Tags'
  task :boot  => :environment do
    puts "Loading documents from #{Repository.repository}"
    count = Repository.create_documents { |count| print "#{count}\r"; $stdout.flush }
    puts "#{count} documents loaded"

    puts "Loading tags from #{Repository.repository}"
    count = Repository.create_tags { |count| print "#{count}\r"; $stdout.flush }
    puts "#{count} tags loaded"
  end
end

namespace :html do
  desc 'Rebuild HTML index'
  task :index => :environment do
    puts Repository.create_html_index
  end
end

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
      doc.write_tags_to_repo
      doc.read_tags_from_repo
      doc.save!
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
  desc 'Info local svn repo'
  task :info => :environment do
    puts Repository.info
  end

  desc 'Stat local svn repo'
  task :status => :environment do
    puts Repository.status
  end

  desc 'Update local svn repo'
  task :update => :environment do
    puts Repository.update
  end

  desc 'Commit local svn repo'
  task :commit => :environment do
    puts Repository.commit
  end

  desc 'Revert local svn repo'
  task :revert => :environment do
    puts Repository.revert
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
