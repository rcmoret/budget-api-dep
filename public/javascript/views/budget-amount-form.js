var app = app || {};

app.BudgetAmountFormView = Backbone.View.extend({
  template: _.template($('#budget-amount-form-template').html()),
  initialize: function(model) {
    this.model = model
    this.displayAttrs = this.displayAttrs()
  },
  events: {
    'click span.submit i.fa-check': 'saveAmount',
    'blur input[name="amount"]': 'saveAmount',
    'keyup input[name="amount"]': 'saveAmount'
  },
  displayAttrs: function() {
    return _.extendOwn(_.clone(this.model.attributes), { _month: app.dateParams.month, year: app.dateParams.year })
  },
  render: function() {
    this.$el.html(this.template(this.displayAttrs))
    this.$el.addClass('budget-amount-form')
    return this.$el
  },
  saveAmount: function(e) {
    if ((e.type === 'keyup' && e.keyCode === ENTER_KEY) || e.type === 'focusout' || e.type === 'click') {
      this.model.set('amount', this.$el.find("input").val())
      this.model.save()
    }
  }
})
