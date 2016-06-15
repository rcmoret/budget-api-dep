var app = app || {};

app.BudgetAmountView = Backbone.View.extend({
  template: _.template($('#budget-amount-template').html()),
  events: {
    'click .amount.editable': 'renderAmountField',
    'blur .amount input': 'updateAmount'
  },
  initialize: function(record) {
    this.model = record
    this.listenTo(this.model, 'rerender', this.render)
  },
  textInput: function(name) {
    return $('<input type="text" name="' + name + '">');
  }
});

app.MonthlyAmountView = app.BudgetAmountView.extend({
  className: 'budget-amount',
  events: function(){
    return _.extend({}, app.BudgetAmountView.prototype.events, {
      'keyup .amount input': 'updateAmount'
    })
  },
  render: function() {
    this.$el.html('')
    this.$el.html(this.template(this.model.attributes))
    this.$el.find('.amount').addClass('editable')
    return this.$el
  },
  renderAmountField: function(e) {
    var el = $(e.toElement)
    var data = el.data()
    el.html(this.textInput(data.name))
    el.find('input').val(data.value).focus()
  },
  updateAmount: function(e) {
    if (e.type === 'keyup' && e.keyCode === ESC_KEY) {
      var el = $(e.target).parent();
      el.html('');
      el.html(el.data('value'))
      return
    } else if ((e.type === 'keyup' && e.keyCode == ENTER_KEY) || e.type == 'focusout') {
      this.model.update({amount: e.target.value})
    }
  }
});

app.WeeklyAmountView = app.BudgetAmountView.extend({
  summaryTemplate: _.template($('#summary-template').html()),
  events: function(){
    return _.extend({}, app.BudgetAmountView.prototype.events, {
      'click i.fa-caret-right': 'showSummary',
      'click i.fa-caret-down': 'compressSummary',
      'keyup .amount input': 'updateAmount'
    })
  },
  showSummary: function() {
    this.$el.html('')
    this.$el.addClass('show-summary')
    this.$el.html(this.summaryTemplate(this.summaryAttributes()))
  },
  summaryAttributes: function() {
    return _.extendOwn(this.model.attributes, { spent: this.model.spent() })
  },
  render: function() {
    this.$el.html('')
    if (this.$el.hasClass('show-summary')) {
      this.showSummary()
    } else {
      this.$el.html(this.template(this.model.attributes))
    }
    return this.$el
  },
  compressSummary: function() {
    this.$el.html(this.template(this.model.attributes))
  },
  renderAmountField: function(e) {
    var el = $(e.toElement)
    this.showSummary()
    var data = this.$el.find('.editable.amount').data()
    this.$el.find('.editable.amount').html(this.textInput(data.name))
    this.$el.find('.editable.amount input').val(data.value).focus()
  },
  updateAmount: function(e) {
    if (e.type === 'keyup' && e.keyCode === ESC_KEY) {
      var el = $(e.target).parent();
      el.html('');
      el.html(el.data('value'))
      return
    } else if ((e.type === 'keyup' && e.keyCode == ENTER_KEY) || e.type == 'focusout') {
      this.model.update({amount: e.target.value})
    } else {
      this.updateCalculations(e)
    }
  },
  updateCalculations: function(e) {
    var budgeted = parseFloat(e.target.value)
    var spent = this.$el.find('.underlined').data('spent')
    var remaining = Math.abs(budgeted - spent)
    this.$el.find('.remaining').html('$' + remaining.toFixed(2))
  }
})
