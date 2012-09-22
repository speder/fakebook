module ApplicationHelper
  def exploded(str)
    str.downcase.split(/\.*/).join(' ')
  end
end
