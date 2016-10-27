var app = app || {};

app.BudgetAmountFormView = Backbone.View.extend({
  template: _.template($('#budget-amount-form-template').html()),
  initialize: function(model, parentView) {
    this.model = model
    this.parentView = parentView
    this.displayAttrs = this.displayAttrs()
  },
  events: {
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
      this.model.save({ 'amount': this.$el.find('input').val() }, {
        success: function(data) {
          app.MonthlyAmounts.fetch({reset: true, data: app.dateParams, processData: true})
          app.WeeklyAmounts.fetch({reset: true, data: app.dateParams, processData: true})
        }
      })
      this.parentView.rerender()
    }
  }
})
