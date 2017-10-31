var app = app || {};

app.BudgetAmountTransactionView = Backbone.View.extend({
  className: 'budget-amount-transaction',
  template: _.template($('#budget-amount-transaction-template').html()),
  initialize: function(model) {
    this.model = model
  },
  events: { },
  render: function() {
    this.$el.html(this.template(this.displayAttrs()));
    return this.$el;
  },
  displayDate: function() {
    if (this.model.get('clearance_date')) {
      var date = this.model.get('clearance_date').split('-');
      return (date[1] + '/' + date[2])
    } else {
      return 'pending'
    }
  },
  displayAttrs: function() {
    return _.extendOwn(this.model.attributes, {
      clear_date: this.displayDate(),
    })
  },
});
