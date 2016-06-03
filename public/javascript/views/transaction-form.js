var app = app || {};

app.TransactionFormView = Backbone.View.extend({
  template: _.template( $('#transaction-form-template').html() ),
  plusButton: _.template($('#plus-button').html()),
  events: {
    'click i.fa.fa-plus-circle': 'renderForm',
    'click button.submit': 'createTransaction'
  },
  initialize: function(accountId) {
    this.collection = app.Accounts.get(accountId).transactions
    this.listenTo(app.ActiveItems, 'reset', this.populateSelect);
    this.newTransaction = new app.Transaction({account_id: accountId});
    this.$el.html(this.plusButton);
  },
  render: function() {
    return this.$el;
  },
  populateSelect: function() {
    _.each(app.ActiveItems.models, function(item) {
      this.$el.find('select').append(this.optionEl(item))
    }, this)
  },
  optionEl: function(item) {
    opt =  '<option value="' + item.id + '">'
    opt += (item.get('name') + ' $' + parseFloat(item.get('remaining')).toFixed(2))
    opt += '</option>'
    return $(opt)
  },
  createTransaction: function() {
    _.each(this.$el.find('input, select'), function(input) {
      if (!_.isUndefined(input.value) && input.value != '') {
        this.newTransaction.attributes[input.name] = input.value
      }
    }, this)
    this.collection.create(this.newTransaction)
  },
  renderPlusButton: function() {
    return this.plusButton()
  },
  renderForm: function() {
    app.ActiveItems.fetch({reset: true})
    this.$el.html('')
    this.$el.html(this.template);
  }
});
