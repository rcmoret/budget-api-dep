var app = app || {};

app.InitialBalanceView = Backbone.View.extend({
  template: _.template( $('#transaction-template').html() ),
  initialize: function(metadata) {
    this.attrs = this.attrs(metadata);
    this.$el.html(this.template(this.attrs));
  },
  attrs: function(metadata) {
    var date = metadata.date_range[0].split('-');
    return {
      id: '0',
      balance: parseFloat(metadata.prior_balance).toFixed(2),
      displayDate: date[1] + '/' + date[2] + '/' + date[0],
      displayDescription: 'Initial Balance',
      displayAmount: parseFloat(metadata.prior_balance).toFixed(2),
      amount: metadata.prior_balance,
      check_number: null,
      notes: null,
      budgetItems: null
    }
  },
  render: function() {
    return this.$el;
  }
});
