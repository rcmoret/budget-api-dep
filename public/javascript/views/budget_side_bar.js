var app = app || {};

app.BudgetSidebarView = Backbone.View.extend({
  className: 'budget-block',
  template: _.template($('#budget-sidebar').html()),
  initialize: function(dateParams) {
    this.dateParams = dateParams
    this.listenTo(app.ActiveMonthlyItems, 'reset', this.updateSelect)
  },
  events: {
    'change #budget-items': 'populateDefaultVal',
    'click span.submit': 'addBudgetAmount'
  },
  render: function() {
    this.$el.html(this.template(this.monthYear()))
    app.ActiveMonthlyItems.fetch({reset: true})
    return this.$el
  },
  updateSelect: function() {
    _.each(app.ActiveMonthlyItems.models, function(item) {
      this.$el.find('select').append(this.optionEl(item));
    }, this)
  },
  optionEl: function(item) {
    var data = 'data-amount="' + item.get('default_amount') + '"'
    var opt = $('<option ' + data + '>' + item.get('name') + '</option>')
    opt.val(item.id)
    return opt
  },
  populateDefaultVal: function(e) {
    var val = $(e.target).find('option:selected').data('amount')
    this.$el.find('input[name="amount"]').val(val)
  },
  addBudgetAmount: function(e) {
    var budgetMonth = (this.month < 10 ? '0' + this.month : this.month) + '|' + this.year
    var item_id = this.$el.find('select').val()
    var amt = this.$el.find('input[name="amount"]').val()
    var newAmount = new app.BudgetAmount({
      month: budgetMonth,
      item_id: item_id,
      amount: amt
    })
    newAmount.save(null,{
      success: function(data) {
        var date = data.get('month').split('|')
        app.MonthlyAmounts.fetch({reset: true, data: this.dateParams, processData: true})
        app.WeeklyAmounts.fetch({reset: true, data: this.dateParams, processData: true})
        app.WeeklyAmounts.trigger('updateDiscretionary')
      }
    })
  },
  monthYear: function() {
    var month = (this.dateParams['month'] || (new Date).getMonth() + 1)
    var year = (this.dateParams['year'] || (new Date).getFullYear())
    return { month: month, year: year }
  }
})
