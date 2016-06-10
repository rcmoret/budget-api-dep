var app = app || {};

app.AccountView = Backbone.View.extend({
  template: _.template( $('#account-template').html() ),
  formTemplate: _.template($('#transaction-form-template').html()),
  initialize: function(account) {
    this.model = account;
    this.listenTo(this.model.transactions, 'reset', this.renderTransactions);
    this.listenTo(this.model, 'fetch', this.updateBalance);
    this.$el.html(this.template(this.model.attributes));
  },
  render: function() {
    return this.$el;
  },
  select: function() {
    if ( !this.selected() ) {
      $('.account.selected #transactions').html('');
      $('.account').removeClass('selected');
      this.$el.addClass('selected');
    };
    this.model.transactions.fetch({reset: true});
  },
  selected: function() {
    return this.$el.hasClass('selected');
  },
  initialBalance: function() {
    var initial = new app.InitialBalanceView(this.model.transactions.metadata);
    $('#transactions').append(initial.render());
    return initial.attrs.amount;
  },
  renderTransactions: function() {
    expandedIds = _.map($('#transactions .expanded'), function(t) {
      return parseInt($(t).attr('id'))
    })
    $('#transactions').html('');
    this.$el.addClass('selected');
    balance = this.initialBalance();
    this.model.transactions.each(function(transaction) {
      balance += transaction.get('amount');
      var view = new app.TransactionView(transaction, balance);
      var expanded = _.contains(expandedIds, view.id)
      $('#transactions').append(view.render(expanded));
    }, this);
    $('#transactions').append(this.plusButton());
  },
  plusButton: function() {
    var row = new app.TransactionFormView(this.id);
    return row.render().$el;
  },
  updateBalance: function() {
  }
});
