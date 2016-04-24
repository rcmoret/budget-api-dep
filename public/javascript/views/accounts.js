var app = app || {};

app.AccountsView = Backbone.View.extend({
  el: 'ul#accounts-list',
  tagName: 'li', //is this line needed?
  template: _.template( $('#account-template').html() ),
  initialize: function(){
    this.collection = app.Accounts;
    this.listenTo(app.Accounts, 'reset', this.render);
  },
  render: function() {
    $('ul#accounts-list').html('');
    this.collection.each(function( account ) {
      var view = new app.AccountView(account);
      this.$el.append(view.render());
    },
    this );
  }
});
