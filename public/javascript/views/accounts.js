var app = app || {};

app.AccountsView = Backbone.View.extend({
  el: '#tab-list',
  template: _.template( $('#account-template').html() ),
  initialize: function() {
    this.collection = app.Accounts;
  },
  render: function() {
    this.$el.html('');
    var context = this
    this.collection.fetch({reset: true}).then(function() {
      _.each(context.collection.models, function(account) {
        var view = new app.AccountView(account)
        context.$el.append(view.$el);
      })
    })
    $('#account-content').append($('<div><div class="transaction"><h2>Select an Account</h2></div></div>'))
  }
});
