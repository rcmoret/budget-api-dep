var app = app || {};

app.BudgetAmount = Backbone.Model.extend({
  initialize: function() {
    _.bindAll(this, 'rerender');
    this.url = '/items/' + this.get('item_id') + '/amount/' + this.id
  },
  className: function() {
    return this.attributes['amount'] < 0 ? 'expenses' : 'revenues'
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
  },
  update: function(attrs, options = {save: true}) {
    this.set(attrs)
    if (options.save) {
      this.save(null, {
        success: this.rerender
      })
      return
    }
  },
  rerender: function() {
    this.trigger('rerender')
    this.collection.trigger('updateDiscretionary')
  },
  spent: function() {
    return (this.get('amount') - this.get('remaining'))
  }
});
