(function() {
  var Health, HealthView, Job, JobItemView, Jobs, JobsCollection, JobsView, health, health_view, jobs_view, refresh_data,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  Job = (function(_super) {

    __extends(Job, _super);

    function Job() {
      return Job.__super__.constructor.apply(this, arguments);
    }

    return Job;

  })(Backbone.Model);

  JobsCollection = (function(_super) {

    __extends(JobsCollection, _super);

    function JobsCollection() {
      return JobsCollection.__super__.constructor.apply(this, arguments);
    }

    JobsCollection.prototype.model = Job;

    JobsCollection.prototype.url = '/stats';

    return JobsCollection;

  })(Backbone.Collection);

  Jobs = new JobsCollection;

  Jobs.comparator = function(p) {
    return p.get('name');
  };

  Health = (function(_super) {

    __extends(Health, _super);

    function Health() {
      return Health.__super__.constructor.apply(this, arguments);
    }

    Health.prototype.url = '/health';

    return Health;

  })(Backbone.Model);

  JobItemView = (function(_super) {

    __extends(JobItemView, _super);

    function JobItemView() {
      this.render = __bind(this.render, this);
      return JobItemView.__super__.constructor.apply(this, arguments);
    }

    JobItemView.prototype.tagName = 'article';

    JobItemView.prototype.className = 'job';

    JobItemView.prototype.template = _.template($('#tmpl-job').html());

    JobItemView.prototype.render = function() {
      this.$el.html(this.template(this.model.toJSON()));
      return this.el;
    };

    return JobItemView;

  })(Backbone.View);

  JobsView = (function(_super) {

    __extends(JobsView, _super);

    function JobsView() {
      this.render = __bind(this.render, this);
      return JobsView.__super__.constructor.apply(this, arguments);
    }

    JobsView.prototype.tagName = 'div';

    JobsView.prototype.id = 'jobs';

    JobsView.prototype.render = function() {
      var _this = this;
      this.$el.empty();
      this.model.forEach(function(p) {
        var v;
        v = new JobItemView({
          model: p
        });
        v.render();
        return _this.$el.append(v.el);
      });
      return this.el;
    };

    return JobsView;

  })(Backbone.View);

  HealthView = (function(_super) {

    __extends(HealthView, _super);

    function HealthView() {
      this.render = __bind(this.render, this);
      return HealthView.__super__.constructor.apply(this, arguments);
    }

    HealthView.prototype.tagName = 'div';

    HealthView.prototype.id = 'health';

    HealthView.prototype.template = _.template($('#tmpl-health').html());

    HealthView.prototype.render = function() {
      this.$el.html(this.template(this.model.toJSON()));
      $("#heap-usage .prop-value").filesize();
      return this.el;
    };

    return HealthView;

  })(Backbone.View);

  health = new Health;

  jobs_view = new JobsView({
    model: Jobs,
    el: $('#job-list')
  });

  health_view = new HealthView({
    model: health,
    el: $('#health')
  });

  refresh_data = function() {
    console.debug("refreshing data");
    return Jobs.fetch({
      success: function() {
        jobs_view.render();
        return health.fetch({
          success: function() {
            var $spy;
            health_view.render();
            return $spy = $('[data-spy="scroll"]').each(function() {
              return $(this).scrollspy('refresh');
            });
          }
        });
      }
    });
  };

  $(function() {
    return refresh_data();
  });

  setInterval(refresh_data, 60 * 1000);

  this.ellipsis = function(str, max) {
    var delta, fifth, len;
    len = str.length;
    if (len < max) {
      return str;
    }
    fifth = Math.round(max / 5);
    console.log(fifth);
    delta = len - max;
    str = str.slice(0, fifth + 1 || 9e9) + "..." + str.slice(fifth + delta, len + 1 || 9e9);
    return str;
  };

  jQuery.timeago.settings.strings = {
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
  };

}).call(this);
