var app = app || {};

app.TransactionFormView = Backbone.View.extend({
  template: _.template( $('#transaction-form-template').html() ),
  plusButton: _.template($('#plus-button').html()),
  events: {
    'click .render-form': 'renderForm',
    'click button.submit': 'createTransaction',
    'click i.fa.fa-close': 'closeForm',
    'click a.add-subtransactions': 'addSubtransactions',
    'keyup .subtransaction-form input[name="amount"]': 'updateAmount'
  },
  initialize: function(accountId) {
    this.collection = app.Accounts.get(accountId).transactions
    this.listenTo(app.ActiveItems, 'reset', this.populateSelect);
    this.$el.html(this.plusButton);
    this.accountId = accountId;
  },
  render: function() {
    return this;
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
    newTransaction = new app.Transaction();
    newTransaction.set('account_id', this.accountId)
    newTransaction.collection = this.collection
    _.each(this.$el.find('.primary input, .primary select'), function(input) {
      if (!_.isUndefined(input.value) && input.value != '' && !input.disabled) {
        newTransaction.set(input.name, input.value)
      }
    }, this)
    newTransaction.set('subtransactions_attributes', this.subtransactionsAttrs())
    newTransaction.save()
    this.collection.add(newTransaction)
  },
  subtransactionsAttrs: function() {
    var attrs = {}
    var index = 0
    _.each(this.$el.find('.subtransaction-form'), function(sub) {
      attrs[index] = {}
      _.each($(sub).find('input, select'), function(input) {
       if (!_.isUndefined(input.value) && input.value != '' && !input.disabled) {
         attrs[index][input.name] = input.value
       }
      })
      index++
    })
    return attrs
  },
  renderPlusButton: function() {
    return this.plusButton()
  },
  renderForm: function() {
    this.$el.html('')
    this.$el.html(this.template);
    app.ActiveItems.fetch({reset: true})
  },
  closeForm: function() {
    this.$el.html('')
    this.$el.html(this.plusButton);
  },
  addSubtransactions: function() {
    if (this.$el.find('.subtransaction-form').length === 0) {
      this.disableFormFields();
      this.addSubtranction();
    }
    this.addSubtranction();
  },
  subForm: _.template($('#subtransaction-form-template').html()),
  addSubtranction: function() {
    this.$el.append(this.subForm({opts: app.ActiveItems.models}))
  },
  disableFormFields: function() {
    this.$el.find('input[name="amount"]').attr('disabled', true)
    this.$el.find('select[name="monthly_amount_id"]').attr('disabled', true)
    this.$el.find('select[name="monthly_amount_id"]').val('')
  },
  updateAmount: function() {
    var targetInput = this.$el.find('.primary input[name="amount"]')
    var total = _.reduce($('.subtransaction-form input[name="amount"]'),
      function(memo, input) {
        var amt = $.isNumeric(input.value) ? parseFloat(input.value) : 0
        return memo += amt
      }, 0
    )
    targetInput.val(total.toFixed(2))
    return
  }
});
