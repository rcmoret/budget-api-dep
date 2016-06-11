var app = app || {};

app.AccountsView = Backbone.View.extend({
  el: '#tab-list',
  template: _.template( $('#account-template').html() ),
  initialize: function() {
    this.collection = app.Accounts;
    this.listenTo(this.collection, 'reset', this.render);
  },
  render: function() {
    this.$el.html('');
    this.collection.each(function( account ) {
      var view = new app.AccountView(account);
      this.$el.append(view.$el);
    },
    this );
    return this
  },
  renderTransactions: function(id) {
    if (this.collection.get(id)) {
      this.collection.get(id).transactions.fetch({reset: true});
    } else {
      this.collection.fetch({
        reset: true,
        success: function(accounts) {
          accounts.get(id).transactions.fetch({reset: true});
        }
      })
    }
  }
});
