var app = app || {};

app.AccountView = Backbone.View.extend({
  tagName: 'li',
  template: _.template( $('#account-template').html() ),
  initialize: function(){
    this.collection = app.Accounts;
    this.listenTo(app.Accounts, 'reset', this.render);
  },
  render: function() {
    $('ul#accounts-list').html('');
    this.collection.each(function( account ) {
      this.renderAccount(account);
    }, this );
  },
  renderAccount: function( account ) {
    if(account.id === 1) {
      account.transactions.fetch();
    };
    var content = this.$el.html( this.template( account.attributes ) ) ;
    $('ul#accounts-list').append( this.template(account.attributes) );
  }
});
