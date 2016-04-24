var app = app || {};

app.TransactionView = Backbone.View.extend({
  template: _.template( $('#transaction-template').html() ),
  initialize: function(transaction) {
    this.model = transaction;
    this.$el.html(this.template(this.model.attributes));
  },
  render: function() {
    return this.$el;
  }
});
