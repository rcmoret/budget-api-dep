var app = app || {};

app.BudgetAmount = Backbone.Model.extend({
  initialize: function() {
  },
  className: function() {
    return this.attributes['amount'] < 0 ? 'expenses' : 'revenues'
  }
});
