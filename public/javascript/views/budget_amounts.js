var app = app || {};

app.BudgetAmountsView = Backbone.View.extend({
  className: 'budget-block',
  amountTemplate: _.template($('#budget-amount-template').html()),
  renderItems: function() {
    this.clearItems();
    _.each(this.collection.sort().models, this.renderItem)
  },
  renderItem: function(item) {
    var view = this.budgetAmountView(item)
    this.$el.find('.budget-wrapper.' + item.className()).append(view.render());
  },
  clearItems: function() {
    _.each(this.$el.find('.budget-wrapper'), function(el) {
      if (_.isUndefined($(el).attr('id'))) {
        $(el).html('')
      }
    })
  },
  currentMonth: function() {
    return _.isUndefined(this.dateParams['month'])
  }
})

app.MonthlyAmountsView = app.BudgetAmountsView.extend({
  template: _.template($('#monthly-template').html()),
  id: 'monthly-amounts',
  initialize: function(dateParams) {
    this.dateParams = dateParams;
    this.collection = app.MonthlyAmounts;
    this.listenTo(this.collection, 'reset', this.renderItems);
    this.listenTo(this.collection, 'change', this.updateDiscretionary);
    _.bindAll(this, 'renderItem')
  },
  render: function() {
    this.$el.html('')
    var month = this.dateParams['month'] || (new Date).getMonth() + 1
    this.$el.html(this.template({ current: this.currentMonth(), month: month }));
    this.collection.fetch({reset: true, data: this.dateParams, processData: true})
    return this.$el;
  },
  budgetAmountView: function(record) {
    return new app.MonthlyAmountView(record)
  }
});

app.WeeklyAmountsView = app.BudgetAmountsView.extend({
  template: _.template($('#weekly-template').html()),
  id: 'weekly-amounts',
  initialize: function(dateParams) {
    this.dateParams = dateParams
    this.collection = app.WeeklyAmounts;
    this.listenTo(this.collection, 'reset', this.renderItems);
    this.listenTo(this.collection, 'change', this.renderDiscretionary);
    _.bindAll(this, 'renderItem')
    this.$el.html(this.template());
  },
  render: function() {
    this.collection.fetch({reset: true, data: this.dateParams, processData: true})
    return this.$el;
  },
  budgetAmountView: function(record) {
    return new app.WeeklyAmountView(record)
  }
});
