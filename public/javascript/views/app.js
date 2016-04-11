var app = app || {};

app.AppView = Backbone.View.extend({
  el: 'section#accounts',

  initialize: function() {
    // this.listenTo(app.Accounts, 'all', this.addAllAccounts);
  },

  render: function() {
  },

  addAllAccounts: function() {
    this.$('section#accounts').html('');
    app.Accounts.each(this.addOneAccount, this)
  },

  addOneAccount: function( account ) {
    var view = new app.AccountView({ model: account });
    $('section#accounts').append( view.render().el );
  }
});
