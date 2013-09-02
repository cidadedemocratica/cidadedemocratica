
class Time
  def day_countdown
    time = self.end_of_day - self
    [:hour, :minute, :second].map do |diff|
      value = (time / 1.send(diff)).to_i % 60
      value.to_s.rjust(2, "0")
    end.join(':')
  end
end
