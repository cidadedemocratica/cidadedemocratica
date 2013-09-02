require "csv"

class CSV
  class << self
    alias_method :generate_without_force_iso, :generate
    def generate(*args, &block)
      data = generate_without_force_iso(*args, &block)
      data.encode(Encoding::ISO_8859_1, Encoding::UTF_8, :undef => :replace)
    end
  end

  alias_method :add_row_without_remove_spaces, :<<
  def <<(row)
    row = row.map { |v| v.gsub(/\s+/, ' ').strip rescue v } if row.is_a? Array
    add_row_without_remove_spaces(row)
  end
  alias_method :add_row, :<<
  alias_method :puts,    :<<
end
