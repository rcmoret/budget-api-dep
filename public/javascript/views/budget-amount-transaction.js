var app = app || {};

app.BudgetAmountTransactionView = Backbone.View.extend({
  className: 'budget-amount-transaction',
  template: _.template($('#budget-amount-transaction-template').html()),
  initialize: function(model) {
    this.model = model
  },
  events: { },
  render: function() {
    this.$el.html(this.template(this.model.attributes));
    return this.$el;
  }
});
