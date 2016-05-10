app = app || {};

app.Transaction = Backbone.Model.extend({
  initialize: function() {
    urlRoot: this.collection.url
  },
  displayDescription: function() {
    if (this.get('description') || this.get('budget_item')) {
      return this.get('description') || this.get ('budget_item')
    } else {
      return parseFloat(this.get('amount')) > 0 ? 'Deposit' : 'Discretionary'
    }
  },
  displayDate: function() {
    if (this.get('clearance_date') != null) {
      var date = this.get('clearance_date').split('-');
      return (date[1] + '/' + date[2] + '/' + date[0])
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
  },
  update: function(attrs, options = {save: false}) {
    this.set(attrs)
    if (options.save) {
      this.save(null, {
        success: function(model, resp) {
          app.Accounts.get(model.get('account_id')).transactions.fetch({reset: true});
        }
      })
      return
    }
  }
});
