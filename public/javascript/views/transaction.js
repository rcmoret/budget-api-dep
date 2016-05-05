var app = app || {};

app.TransactionView = Backbone.View.extend({
  template: _.template( $('#transaction-template').html() ),
  subTemplate: _.template( $('#subtransaction-template').html() ),
  initialize: function(transaction, balance) {
    this.model = transaction;
    this.balance = balance;
    this.$el.html(this.template(this.viewAttrs()));
  },
  render: function() {
    if (this.model.subtransactions().length > 0) {
      this.$el.find('.transaction').append(this.subtransactionElement());
      _.each(this.model.subtransactions(), function(sub) {
        this.$el.find('ul.subtransactions').append(this.subTemplate(sub));
      }, this);
    }
    return this.$el;
  },
  subtransactionElement: function() {
    return $('<ul class="subtransactions collapsed"></ul>')
  },
  viewAttrs: function() {
    console.log(this.model.attributes)
    return _.extend(this.model.attributes, { balance: this.balance.toFixed(2) })
  }
});
