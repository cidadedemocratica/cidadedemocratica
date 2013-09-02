module MarkdownHelper
  def markdown(text)
    if text
      content_tag :div, Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(text).html_safe, :class => 'markdown'
    end
  end
end
