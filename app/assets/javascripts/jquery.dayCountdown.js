jQuery(document).ready(function($) {
  function Time(value) {
    this.value = value
  }

  Time.partials = ['hour', 'minute', 'second']
  Time.partials.hour = 60 * 60
  Time.partials.minute = 60
  Time.partials.second = 1

  Time.prototype.down = function () {
    this.value = Math.max(0, this.value - 1)
  }

  Time.prototype.toString = function () {
    var data = [],
        self = this
    $.each(Time.partials, function (i, partial) {
      var value = (self.value / Time.partials[partial]).floor() % 60
      data.push(('0' + value).substr(-2))
    })
    return data.join(':')
  }

  Time.fromString = function (str) {
    var data = str.split(':'),
        time = 0
    $.each(Time.partials, function (i, partial) {
      time += data[i] * Time.partials[partial]
    })
    return new Time(time)
  }

  $('.day_countdown').each(function () {
    var container = $(this)
      , time = Time.fromString(container.html())

    function step() {
      time.down()
      container.html(time.toString())
    }

    setInterval(step, 1000)
  })
})
