var app = app || {};

app.InitialBalanceView = Backbone.View.extend({
  template: _.template( $('#transaction-template').html() ),
  initialize: function(metadata) {
    this.attrs = this.attrs(metadata);
    this.$el.html(this.template(this.attrs));
  },
  attrs: function(metadata) {
    var date = metadata.date_range[0].split('-');
    return {
      id: '0',
      balance: metadata.prior_balance,
      clear_date: date[1] + '/' + date[2] + '/' + date[0],
      clearance_date: null,
      description: null,
      displayDescription: 'Initial Balance',
      amount: metadata.prior_balance,
      check_number: null,
      notes: null,
      budgetItems: null,
      subtransactions_attributes: []
    }
  },
  render: function() {
    this.$el.find('.editable').removeClass('editable')
    this.$el.find('.fa-list-ul').removeClass('fa-list-ul')
    this.$el.find('.fa-edit').removeClass('fa-edit')
    return this.$el;
  }
});
