var app = app || {};

app.AccountView = Backbone.View.extend({
  tagName: 'li',
  template: _.template( $('#account-template').html() ),
  events: { },
  initialize: function(account) {
    this.model = account;
    this.listenTo(this.model.transactions, 'reset', this.renderTransactions);
    this.$el.html(this.template(this.model.attributes));
  },
  render: function() {
    return this.$el;
  },
  select: function() {
    if ( !this.selected() ) {
      $('.account.selected .transactions').html('');
      $('.account').removeClass('selected');
      this.$el.find('.account').addClass('selected');
    };
    this.model.transactions.fetch({reset: true});
  },
  selected: function() {
    return this.$el.find('.account').hasClass('selected');
  },
  initialBalance: function() {
    var initial = new app.InitialBalanceView(this.model.transactions.metadata);
    this.$el.find('.transactions').append(initial.render());
    return initial.attrs.amount;
  },
  renderTransactions: function() {
    this.$el.find('.transactions').html('');
    this.$el.addClass('selected');
    balance = this.initialBalance();
    this.model.transactions.each(function(transaction) {
      balance += transaction.get('amount');
      var view = new app.TransactionView(transaction, balance);
      this.$el.find('.transactions').append(view.render());
    }, this);
  }
});
