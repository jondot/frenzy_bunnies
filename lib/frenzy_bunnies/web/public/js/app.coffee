class Job extends Backbone.Model

class JobsCollection extends Backbone.Collection
  model: Job
  url: '/stats'

Jobs = new JobsCollection
Jobs.comparator = (p)->
  p.get('name')



class Health extends Backbone.Model
  url: '/health'


class JobItemView extends Backbone.View
  tagName: 'article'
  className: 'job'
  template:  _.template $('#tmpl-job').html()

  render:()=>
    @$el.html @template(@model.toJSON())
    @el

class JobsView extends Backbone.View
  tagName: 'div'
  id: 'jobs'

  render:()=>
    @$el.empty()
    @model.forEach (p)=>
      v = new JobItemView(model: p)
      v.render()
      @$el.append(v.el)
    @el

class HealthView extends Backbone.View
  tagName: 'div'
  id: 'health'
  template:  _.template $('#tmpl-health').html()

  render:()=>
    @$el.html @template(@model.toJSON())
    $("#heap-usage .prop-value").filesize()
    @el
health = new Health
jobs_view = new JobsView(model:Jobs, el:$('#job-list'))
health_view = new HealthView(model: health, el:$('#health'))


refresh_data = ()->
  console.debug "refreshing data"
  Jobs.fetch success: ()->
    jobs_view.render()
    health.fetch success: ()->
      health_view.render()
      $spy = $('[data-spy="scroll"]').each ()-> $(this).scrollspy('refresh')


$(()->refresh_data())
setInterval refresh_data, 60*1000

@ellipsis = (str, max)->
  len = str.length
  if len < max
    return str
  fifth = Math.round(max/5)
  console.log(fifth)
  delta = len - max
  str = str[0..fifth] + "..." + str[(fifth+delta)..len]

  str

jQuery.timeago.settings.strings =
  prefixAgo: null,
  prefixFromNow: null,
  suffixAgo: null,
  suffixFromNow: null,
  seconds: "sec",
  minute: "1 min",
  minutes: "%d mins",
  hour: "1 hr",
  hours: "%d hrs",
  day: "1 day",
  days: "%d days",
  month: "1 mo",
  months: "%d mo",
  year: "1 year",
  years: "%d yrs"
