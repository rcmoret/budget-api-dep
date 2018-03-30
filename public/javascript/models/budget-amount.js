var app = app || {};

app.BudgetAmount = Backbone.Model.extend({
  initialize: function() {
    this.cleared = (this.get('remaining') === 0)
    this.transactions = new app.BudgetAmountTransactions(this.get('item_id'), this.id)
  },
  url: function() {
    baseUrl = '/items/' + this.get('item_id') + '/amount'
    if (_.isUndefined(this.id)) {
      return baseUrl
    } else {
      return baseUrl + '/' + this.id
    }
  },
  className: function() {
    return this.attributes['expense'] ? 'expenses' : 'revenues'
  },
});
