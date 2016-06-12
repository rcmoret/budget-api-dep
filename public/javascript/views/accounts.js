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
    $('#content').append($('<div><div class="transaction"><h2>Select an Account</h2></div></div>'))
    return this
  }
});
