var app = app || {};

app.BudgetAmountsView = Backbone.View.extend({
  className: 'budget-block',
  amountTemplate: _.template($('#budget-amount-template').html()),
  renderItems: function() {
    _.each(this.collection.sort().models, this.renderItem)
  },
  renderItem: function(item) {
    var view = this.budgetAmountView(item)
    this.$el.find('.budget-wrapper.' + item.className()).append(view.render());
  },
  dateParams: function() {
    if (!_.isNull(this.month)) {
      if (!_.isNull(this.year)) {
        return { month: this.month, year: this.year }
      } else {
        return { month: this.month }
      }
    } else {
      return {}
    }
  }
})

app.MonthlyAmountsView = app.BudgetAmountsView.extend({
  template: _.template($('#monthly-template').html()),
  id: 'monthly-amounts',
  initialize: function(month, year) {
    this.month = month;
    this.year = year;
    this.collection = app.MonthlyAmounts;
    this.listenTo(this.collection, 'reset', this.renderItems);
    _.bindAll(this, 'renderItem')
  },
  render: function(month) {
    this.$el.html('')
    this.$el.html(this.template());
    console.log(this.dateParams())
    this.collection.fetch({reset: true, data: this.dateParams(), processData: true})
    return this.$el;
  },
  budgetAmountView: function(record) {
    return new app.MonthlyAmountView(record)
  },
});

app.WeeklyAmountsView = app.BudgetAmountsView.extend({
  template: _.template($('#weekly-template').html()),
  id: 'weekly-amounts',
  initialize: function(month, year) {
    this.collection = app.WeeklyAmounts;
    this.month = month;
    this.year = year;
    this.listenTo(this.collection, 'reset', this.renderItems);
    this.listenTo(app.MonthlyAmounts, 'change', this.renderDiscretionary);
    this.listenTo(this.collection, 'updateDiscretionary', this.renderDiscretionary);
    _.bindAll(this, 'renderItem')
    this.discretionaryView = new app.DiscretionaryView(month, year);
    this.$el.html(this.template());
  },
  render: function(month, year) {
    console.log(this.dateParams())
    this.collection.fetch({reset: true, data: this.dateParams(), processData: true})
    return this.$el;
  },
  renderDiscretionary: function() {
    this.$el.find('.budget-wrapper#discretionary').html(
      this.discretionaryView.render(this.dateParams()))
  },
  budgetAmountView: function(record) {
    return new app.WeeklyAmountView(record)
  }
});
