var app = app || {};

app.BudgetAmount = Backbone.Model.extend({
  initialize: function() {
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
    return this.attributes['amount'] < 0 ? 'expenses' : 'revenues'
  },
  },
  spent: function() {
    return (this.get('amount') - this.get('remaining'))
  }
});
