var app = app || {};

app.AccountView = Backbone.View.extend({
  tagName: 'div',
  className: 'account',
  template: _.template( $('#account-template').html() ),
  formTemplate: _.template($('#transaction-form-template').html()),
  initialize: function(account) {
    this.model = account;
    this.listenTo(this.model.transactions, 'sync', this.renderTransactions);
    this.listenTo(this.model.transactions, 'reset', this.updateBalance);
    this.$el.html(this.template(this.model.attributes));
  },
  render: function() {
  },
  select: function() {
    if ( !this.selected() ) {
      $('.account.selected #content').html('');
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
    $('#content').append(initial.render());
    return initial.attrs.amount;
  },
  renderTransactions: function() {
    expandedIds = _.map($('#content .expanded'), function(t) {
      return parseInt($(t).attr('id'))
    })
    $('#content').html('');
    this.$el.addClass('selected');
    balance = this.initialBalance();
    this.model.transactions.each(function(transaction) {
      balance += transaction.get('amount');
      var view = new app.TransactionView(transaction, balance);
      var expanded = _.contains(expandedIds, view.id)
      $('#content').append(view.render(expanded));
    }, this);
    $('#content').append(this.plusButton());
  },
  plusButton: function() {
    var row = new app.TransactionFormView(this.id);
    return row.render().$el;
  },
  updateBalance: function() {
    _this = this
    this.model.fetch({
      success: function(data) {
        _this.$el.find('span.amount strong').html('$' + data.get('balance').toFixed(2))
      }
    })
  }
});
