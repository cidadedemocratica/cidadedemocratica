module ScopedByDateInterval
  extend ActiveSupport::Concern

  included do
    scope :at_interval, ->(from, to) do
      return unless from and to and from.kind_of?(Date) and to.kind_of?(Date)
      where(:created_at => from...to)
    end
  end
end
