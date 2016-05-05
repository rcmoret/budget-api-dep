app = app || {};

app.Transaction = Backbone.Model.extend({
  initialize: function() {
    this.set({displayDescription: this.displayDescription(),
              displayAmount: this.displayAmount(),
              displayDate: this.displayDate(),
              budgetItems: this.items()
    });
  },
  baseUrl: function() {
    return '/accounts/' + this.account_id + '/transactions/'
  },
  url: function() {
    return baseUrl + this.id
  },
  displayDescription: function() {
    if (this.get('description') || this.get('budget_item')) {
      return this.get('description') || this.get ('budget_item')
    } else {
      return parseFloat(this.get('amount')) > 0 ? 'Deposit' : 'Discretionary'
    }
  },
  displayAmount: function() {
    return parseFloat(this.get('amount')).toFixed(2)
  },
  displayDate: function() {
    if (this.get('clearance_date') != null) {
      var date = this.get('clearance_date').split('-')
      return date[1] + '/' + date[2] + '/' + date[0]
    } else {
      return 'pending'
    }
  },
  subtransactions: function() {
    return this.get('subtransactions') || []
  },
  items: function() {
    if (this.subtransactions().length === 0) {
      return this.get('budget_item')
    } else {
      var items = _.map(this.subtransactions(), function (sub) {
        return sub.budget_item
      })
      var filteredItems = _.filter(items, function(item) {
        return item
      })
      return filteredItems.join(', ')
    }
  }
});
