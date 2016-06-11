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
  },
  render: function() {
    this.preRender();
    this.renderDiscretionary();
    this.collection.fetch({reset: true})
    return this.$el;
  },
  renderDiscretionary: function() {
    var discretionary = new app.Discretionary();
    _this = this
    discretionary.fetch({
      success: function(resp) {
        _this.$el.find('.budget-wrapper.discretionary').append(_this.amountTemplate(resp.attributes));
      }
    })
  }
});
