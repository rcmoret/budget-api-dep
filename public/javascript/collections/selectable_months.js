var app = app || {};

app.SelectableMonths = Backbone.Collection.extend({
  model: app.SelectableMonth,
  initialize: function(accountId) {
    this.url = '/accounts/' + accountId + '/selectable_months'
  }
});
