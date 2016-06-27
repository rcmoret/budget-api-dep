app = app || {};

app.Transaction = Backbone.Model.extend({
  initialize: function() {
  },
  defaults: {
    'id': null,
    'clearance_date': null,
    'description': null,
    'amount': null,
    'notes': null,
    'check_number': null,
    'monthly_amount_id': null,
    'subtransactions_attributes': []
  },
  urlRoot: function() {
    return this.collection.url
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
    return this.get('subtransactions_attributes') || {}
  },
  items: function() {
    if (_.isEmpty(this.subtransactions())) {
      return this.get('budget_item')
    } else {
      var itemArray = _.map(this.subtransactions(), function (sub) {
        return sub.budget_item
      })
      var filteredItems = _.filter(itemArray, function(item) {
        return item
      })
      return filteredItems.join(', ')
    }
  }
});
