require 'csv'

class AssociativeMatrix
  attr_reader :members, :associations

  def self.generate(*members)
    new(members)
  end

  def initialize(*data)
    @members = *data
    @associations = resolve_associations
  end

  def unique_members
    @unique_members ||= @members.flatten.uniq.sort
  end

  def to_csv
    CSV.generate do |csv|
      csv << header
      associations.each do |member, collection|
        line = [member] + zero_line
        collection.each do |associated, total|
          index = unique_members.index(associated) + 1
          line[index] = total
        end
        csv << line
      end
    end
  end

  protected

  def zero_line
    Array.new(unique_members.size, 0)
  end

  def header
    ["X"] + unique_members
  end

  def resolve_associations
    data = Hash.new { |hash, key| hash[key] = [] }
    members.each do |collection|
      collection.uniq.each { |member| data[member] += collection }
    end
    data.sort.map do |member, collection|
      [member, collection.group_by(&:to_s).map { |m, g| [m, g.size] }]
    end
  end
end
