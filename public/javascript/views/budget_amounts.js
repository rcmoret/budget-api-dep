var app = app || {};

app.BudgetAmountsView = Backbone.View.extend({
  className: 'budget-block',
  amountTemplate: _.template($('#budget-amount-template').html()),
  preRender: function() {
    this.$el.html('')
    this.$el.html(this.template());
  },
  renderItems: function() {
    _this = this
    _.each(this.collection.models, function(budgetItem) {
      var view = new app.BudgetAmountView(budgetItem);
      _this.$el.find('.budget-wrapper.' + budgetItem.className()).append(view.render());
    })
  },
})

app.MonthlyAmountsView = app.BudgetAmountsView.extend({
  template: _.template($('#monthly-template').html()),
  id: 'monthly-amounts',
  initialize: function() {
    this.collection = app.MonthlyAmounts;
    this.listenTo(this.collection, 'reset', this.renderItems);
  },
  render: function() {
    this.preRender();
    this.collection.fetch({reset: true})
    return this.$el;
  } //,
  // renderItems: function() {
  //   _this = this
  //   _.each(this.collection.models, function(budgetItem) {
  //     var view = new app.BudgetAmountView(budgetItem);
  //     _this.$el.find('.budget-wrapper.' + budgetItem.className()).append(view.render());
  //   })
  // },
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
