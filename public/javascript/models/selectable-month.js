var app = app || {};

app.SelectableMonth = Backbone.Model.extend({
  initialize: function() {
    this.set('isCurrent', this.isCurrent())
  },
  isCurrent: function() {
    if (_.isUndefined(this.get('value'))) {
      return false
    }
    return app.dateParams.month === this.month() && app.dateParams.year === this.year()
  },
  month: function() {
    return parseInt(this.get('value').split('|')[0])
  },
  year: function() {
    return parseInt(this.get('value').split('|')[1])
  }
});
