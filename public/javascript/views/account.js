var app = app || {};

app.AccountView = Backbone.View.extend({
  tagName: 'div',
  className: 'account',
  template: _.template( $('#account-template').html() ),
  formTemplate: _.template($('#transaction-form-template').html()),
  initialize: function(account) {
    this.model = account;
    this.transactions = this.model.transactions;
    _.bindAll(this, 'renderBalance', 'renderDetails', 'renderTransactions', 'renderInitialBalance')
    this.listenTo(this.transactions, 'reset', this.updateBalance);
    this.listenTo(this.transactions, 'change', this.renderDetails);
    this.listenTo(this.transactions, 'add', this.renderDetails);
    this.listenTo(this.model, 'render', this.select);
    this.$el.html(this.template(this.model.attributes));
  },
  events: { },
  render: function() {
  },
  select: function() {
    if (this.$el.hasClass('selected')) {
      return
    } else {
      $('.account').removeClass('selected')
      this.$el.addClass('selected')
      this.renderDetails()
    }
  },
  initialBalance: function() {
    return this.transactions.metadata['prior_balance']
  },
  renderInitialBalance: function() {
    var initial = new app.InitialBalanceView(this.transactions.metadata);
    $('#content').append(initial.render());
  },
  renderTransactions: function() {
    var expandedIds = _.map($('#content .expanded'), function(t) {
      return parseInt($(t).attr('id'))
    })
    $('#content').html('')
    this.renderInitialBalance()
    var balance = this.initialBalance();
    _.each(this.transactions.models, function(transaction) {
      balance += transaction.get('amount');
      var view = new app.TransactionView(transaction, balance);
      var expanded = _.contains(expandedIds, view.id)
      $('#content').append(view.render(expanded));
    }, this);
    $('#content').append(this.plusButton());
  },
  renderDetails: function() {
    this.transactions.fetch({
      reset: true,
      success: this.renderTransactions
    })
  },
  plusButton: function() {
    var row = new app.TransactionFormView(this.id);
    return row.render().$el;
  },
  updateBalance: function() {
    this.model.fetch({
      success: this.renderBalance
    })
  },
  renderBalance: function(data) {
    this.$el.find('span.amount strong').html('$' + data.get('balance').toFixed(2))
  }
});
