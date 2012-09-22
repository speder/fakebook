class Repository
  cattr_accessor :local_path
  @@local_path = APP_CONFIG['svn']['local_path'].dup

  def self.create_documents(options = {}, &block)
    chunk = options.fetch(:chunk, 10)
    Document.delete_all
    entity = HTMLEntities.new
    xml = list
    count = 0
    (Hpricot.XML(xml)/:list/:entry).each do |e|
      next if entity.decode((e/:name).inner_html) =~ /^\./
        Document.create!(
          :name     => entity.decode((e/:name).inner_html),
          :size     => (e/:size).inner_html,
          :date     => DateTime.parse((e/:date).inner_html),
          :author   => (e/:author).inner_html,
          :revision => (e % :commit)[:revision]
      )
      count += 1
      if block_given? and (count < chunk or (count % chunk).zero?)
        yield count
      end
    end
    count
  end

  def self.create_tags(options = {}, &block)
    chunk = options.fetch(:chunk, 10)
    count = 0
    tags.split(/\n/).each do |line|
      next if line.blank?
      name, tags = line.match(/(.*)\/(.*) \- (\[.*\])/)[2..3]
      tags = eval(tags)
      Document.where(:name => name).each do |doc|
        doc.set_tags(tags)
        doc.save!
        count += 1
        if block_given? and (count < chunk or (count % chunk).zero?)
          yield count
        end
      end
    end
    count
  end

  def self.create_html_index
    tag_groups = Document.tags.inject({}) { |hash, tag| hash[tag] = Document.tagged_with(tag); hash }
    doc_groups = Document.alphabetical.group_by { |doc| doc.name.upcase[0..0] }
    @groups = doc_groups.merge(tag_groups)
    @untagged = Document.without_tags
    @recent = Document.new_or_changed_since(@recent_date = 6.weeks.ago)
    template_path = File.expand_path(File.join(Rails.root, 'public/repo/index.html.erb'))
    template = ERB.new(open(template_path, 'r') { |f| f.read })
    html_path = File.expand_path(File.join(local_path, '.fakebook.html'))
    open(html_path, 'w') { |f| f.write(template.result(binding)) }
    html_path
  end

  # name is a String
  def self.get_tags(name)
    svn_command('propget tags --strict', path_for(name))
  end

  # doc is a Document
  def self.set_tags(doc)
    args = if doc.tags.present?
             # before: "John Lennon, Paul Mccartney"
             #  after: "[\"john lennon\",\"paul mccartney\"]"
             ary = doc.tag_list.downcase.split(',')
             str = '"[%s]"' % ary.map{ |t| '\"%s\"' % t.strip }.join(',')
             "propset tags #{str}"
           else
             'propdel tags'
           end
    svn_command(args, path_for(doc.name))
  end

  # handle internal double or single quote(s)
  def self.path_for(name)
    if name =~ /'/
      %(#{local_path}/"#{name}")
    else
      %(#{local_path}/'#{name}')
    end
  end

  # public svn methods

  def self.info
    svn_command('info')
  end

  def self.status(options = {})
    command = ['status']
    command << '--show-updates' if options.fetch(:remote, false)
    svn_command(command.join(' '))
  end

  def self.update
    svn_command('update --force')
  end

  def self.commit(options = {})
    command = ['commit --message']
    command << (options[:ip_address] && %('#{options[:ip_address]}') || %('fakebook.org'))
    command << "--username #{options[:username]}" if options[:username]
    command << "--password #{options[:password]}" if options[:password]
    Rails.logger.warn("[#{Time.now.to_s(:compact)}] svn #{command.join(' ')}")
    svn_command(command.join(' '))
  end

  def self.revert
    svn_command('revert --recursive')
  end

  # private svn methods

  def self.list
    svn_command('list --xml')
  end

  def self.tags
    svn_command('propget tags --recursive')
  end

  def self.svn_command(args, path = nil)
    path ||= local_path
    %x(svn #{args} --no-auth-cache --non-interactive --trust-server-cert #{path})
  end
end
