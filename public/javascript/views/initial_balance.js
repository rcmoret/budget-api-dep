var app = app || {};

app.InitialBalanceView = Backbone.View.extend({
  template: _.template( $('#initial-transaction-template').html() ),
  initialize: function(account, metadata) {
    this.metadata = metadata
    this.account = account
    this.date = this.metadata.date_range[0].split('-');
    this.$el.html(this.template(this.attrs()));
  },
  events: {
    'change select#select-month': 'redirectToMonth'
  },
  attrs: function() {
    return {
      id: '0',
      balance: this.metadata.prior_balance,
      clearance_date: this.date[1] + '/' + this.date[2] + '/' + this.date[0],
      displayDescription: 'Initial Balance',
      amount: this.metadata.prior_balance
    }
  },
  render: function() {
    return this.$el;
  },
  redirectToMonth: function(event) {
    var month = parseInt(event.target.value.split('|')[0])
    var year =  parseInt(event.target.value.split('|')[1])
    Backbone.history.navigate('/accounts/' + this.account.id + '/' + month + '/' + year, true)
  }
});
