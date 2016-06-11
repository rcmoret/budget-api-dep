var app = app || {};

app.BudgetAmountView = Backbone.View.extend({
  template: _.template($('#budget-amount-template').html()),
  initialize: function(record) {
    this.model = record
  },
  render: function() {
    this.$el.html('')
    this.$el.html(this.template(this.model.attributes))
    return this.$el
  }
});
