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
  }
})

app.MonthlyAmountsView = app.BudgetAmountsView.extend({
  template: _.template($('#monthly-template').html()),
  id: 'monthly-amounts',
  initialize: function() {
    this.collection = app.MonthlyAmounts;
    this.listenTo(this.collection, 'reset', this.renderItems);
    _.bindAll(this, 'renderItem')
  },
  render: function() {
    this.$el.html('')
    this.$el.html(this.template());
    this.collection.fetch({reset: true})
    return this.$el;
  },
  budgetAmountView: function(record) {
    return new app.MonthlyAmountView(record)
  }
});

app.WeeklyAmountsView = app.BudgetAmountsView.extend({
  template: _.template($('#weekly-template').html()),
  id: 'weekly-amounts',
  initialize: function() {
    this.collection = app.WeeklyAmounts;
    this.listenTo(this.collection, 'reset', this.renderItems);
    this.listenTo(app.MonthlyAmounts, 'updateDiscretionary', this.renderDiscretionary);
    this.listenTo(this.collection, 'updateDiscretionary', this.renderDiscretionary);
    _.bindAll(this, 'renderItem')
    this.discretionaryView = new app.DiscretionaryView();
    this.$el.html(this.template());
    this.collection.fetch({reset: true})
  },
  render: function() {
    this.collection.fetch({reset: true})
    return this.$el;
  },
  renderDiscretionary: function() {
    this.$el.find('.budget-wrapper#discretionary').html(this.discretionaryView.render())
  },
  budgetAmountView: function(record) {
    return new app.WeeklyAmountView(record)
  }

});
