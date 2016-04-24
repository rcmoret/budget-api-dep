var app = app || {};

app.AccountView = Backbone.View.extend({
  tagName: 'li',
  template: _.template( $('#account-template').html() ),
  id: function(){
    this.model.id
  },
  events: {
    'click a': 'select'
  },
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
  renderTransactions: function() {
    this.$el.find('.transactions').html('');
    this.model.transactions.each(function(transaction) {
      var view = new app.TransactionView(transaction);
      this.$el.find('.transactions').append(view.render());
    }, this);
  }
});
