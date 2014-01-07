module ApplicationHelper
  def by_tag
    'b y &middot; t a g'.html_safe
  end

  def by_title
    'b y &middot; t i t l e'.html_safe
  end

  def exploded(str)
    str.downcase.split(/\.*/).join(' ')
  end

  def _initialize
    'i n i t i a l i z e'
  end

  def save_changes
    's a v e &middot; c h a n g e s'.html_safe
  end
end
