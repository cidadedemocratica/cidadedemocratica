(function($) {
  'use strict'

  function ActivitiesFeed(settings) {
    this.settings = settings
    this.container = $(settings.container)
    if (this.container.length) {
      settings.twitter && this.getDataFromTwitter()
    }
  }

  ActivitiesFeed.prototype.getDataFromTwitter = function() {
    $.ajax({
      url: 'http://api.twitter.com/1/statuses/user_timeline.json',
      dataType: 'jsonp',
      data: {
        screen_name: this.settings.twitter.user,
        include_rts: true,
        count: this.settings.twitter.numTweets,
        include_entities: true
      },
      success: $.proxy(this, 'processDataFromTwitter')
    })
  }

  ActivitiesFeed.prototype.normalizeDateFromTwitter = function (date) {
    return Date.parse(date) || Date.parse(date.replace(/( \+)/, ' UTC$1'))
  }

  ActivitiesFeed.prototype.processDataFromTwitter = function (data) {
    var makeItem = $.proxy(function (info) {
      var text = ify.clean(info.text),
          date = this.normalizeDateFromTwitter(info.created_at)
      return this.item("Twitter", text, date)
    }, this)
    this.render($.map(data, makeItem))
  }

  ActivitiesFeed.prototype.item = function (label, text, date) {
    var data = {
          time: parseInt(date / 1000, 10),
          label: label,
          text: text,
          distanceOfTime: distanceOfTime(date)
        },
        html = this.settings.template.replace(/{{(\w+)}}/g, function(m, key){
          return data[key]
        })
    return {
      time: data.time,
      element: $(html)
    }
  }

  ActivitiesFeed.prototype.containerItens = function () {
    return $.map(this.container.children(), function (element) {
      element = $(element)
      return {
        time: element.data('time'),
        element: element
      }
    })
  }

  ActivitiesFeed.prototype.render = function (itensToAdd) {
    var itens = this.containerItens().concat(itensToAdd),
        holder = $('<div>')

    itens = itens.sort(function (a, b) {
      return a.time - b.time
    }).reverse()

    $.each(itens, function (i, item) {
      holder.append(item.element)
    })
    this.container.html(holder.html())
  }

  /**
   * Time
   */
  function distanceOfTime(from_time) {
    // inspired by Rails distance_of_time_in_words from DateHelper
    var second = 1000,
        minute = second * 60,
        to_time = new Date(),
        distance_in_minutes = Math.round((to_time - from_time) / minute)

    if (distance_in_minutes === 0)    return 'menos de um minuto'
    if (distance_in_minutes === 1)    return '1 minuto'
    if (distance_in_minutes < 45)     return distance_in_minutes + ' minutos'
    if (distance_in_minutes < 90)     return 'aprox. 1 hora'
    if (distance_in_minutes < 1440)   return 'aprox. ' + (distance_in_minutes / 60).round() + ' horas'
    if (distance_in_minutes < 2520)   return '1 dia'
    if (distance_in_minutes < 43200)  return (distance_in_minutes / 1440).round() + ' dias'
    if (distance_in_minutes < 86400)  return 'aprox. 1 mês'
    if (distance_in_minutes < 525600) return (distance_in_minutes / 43200).round() + ' meses'

    var distance_in_years = distance_in_minutes / 525600,
        minute_offset_for_leap_year = (distance_in_years / 4) * 1440,
        remainder = (distance_in_minutes - minute_offset_for_leap_year) % 525600
    if (remainder < 131400) return 'aprox. ' + (Math.round(distance_in_years)) + 'anos atrás'
    if (remainder < 394200) return 'mais de ' + (Math.round(distance_in_years)) + ' anos atrás'
                            return 'quase ' + (Math.round(distance_in_years + 1)) + ' anos'
  }

  /**
   * Ify
   * The Twitalinkahashifyer!
   * http://www.dustindiaz.com/basement/ify.html
   */
  var ify = {
    link: function(tweet) {
      return tweet.replace(/\b(((https*\:\/\/)|www\.)[^\"\']+?)(([!?,.\)]+)?(\s|$))/g, function(link, m1, m2, m3, m4) {
        var http = m2.match(/w/) ? 'http://' : ''
        return '<a class="twtr-hyperlink" target="_blank" href="' + http + m1 + '">' + ((m1.length > 25) ? m1.substr(0, 24) + '...' : m1) + '</a>' + m4
      })
    },

    at: function(tweet) {
      return tweet.replace(/\B[@＠]([a-zA-Z0-9_]{1,20})/g, function(m, username) {
        return '<a target="_blank" class="twtr-atreply" href="http://twitter.com/intent/user?screen_name=' + username + '">@' + username + '</a>'
      })
    },

    list: function(tweet) {
      return tweet.replace(/\B[@＠]([a-zA-Z0-9_]{1,20}\/\w+)/g, function(m, userlist) {
        return '<a target="_blank" class="twtr-atreply" href="http://twitter.com/' + userlist + '">@' + userlist + '</a>'
      })
    },

    hash: function(tweet) {
      return tweet.replace(/(^|\s+)#(\w+)/gi, function(m, before, hash) {
        return before + '<a target="_blank" class="twtr-hashtag" href="http://twitter.com/search?q=%23' + hash + '">#' + hash + '</a>'
      })
    },

    clean: function(tweet) {
      return this.hash(this.at(this.list(this.link(tweet))))
    }
  }

  /**
   * Run
   */
  $(document).ready(function () {
    new ActivitiesFeed({
      container: '#activity_feed',
      template: '<li data-time="{{time}}"><span class="label">{{label}}:</span> {{text}}<span class="time">há {{distanceOfTime}}</span></li>',
      twitter: {
        user: 'cidademocratica',
        numTweets: 5
      }
    })
  })

})(jQuery)
