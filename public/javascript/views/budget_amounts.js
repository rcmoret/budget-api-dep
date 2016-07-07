var app = app || {};

app.BudgetAmountsView = Backbone.View.extend({
  className: 'budget-block',
  amountTemplate: _.template($('#budget-amount-template').html()),
  renderItems: function() {
    this.clearItems();
    _.each(this.collection.sort().models, this.renderItem)
  },
  clearItems: function() {
    _.each(this.$el.find('.budget-wrapper'), function(el) {
      if (_.isUndefined($(el).attr('id'))) {
        $(el).html('')
      }
    })
  }
})

app.MonthlyAmountsView = app.BudgetAmountsView.extend({
  template: _.template($('#monthly-template').html()),
  id: 'monthly-amounts',
  initialize: function(dateParams) {
    this.dateParams = dateParams;
    this.collection = app.MonthlyAmounts;
    this.listenTo(this.collection, 'reset', this.renderItems);
    _.bindAll(this, 'renderItem')
  },
  events: {
    'click div.see-cleared span': 'toggleCleared'
  },
  render: function() {
    this.$el.html('')
    var month = this.dateParams['month'] || (new Date).getMonth() + 1
    this.$el.html(this.template({ clearedCount: this.clearedCount(), month: month }));
    this.collection.fetch({reset: true, data: this.dateParams, processData: true})
    return this.$el;
  },
  toggleCleared: function(e) {
    _.each(this.collection.models, function(item) {
      if(item.cleared) {
        item.trigger('toggleShow')
      }
    })
    if ($(e.toElement).text() === 'See cleared items') {
      $(e.toElement).text('Hide cleared items')
    } else {
      $(e.toElement).text('See cleared items')
    }
  },
  renderItem: function(item) {
    var view = this.budgetAmountView(item)
    if (item.cleared) {
      this.$el.find('.budget-wrapper.cleared').append(view.render());
    } else {
      this.$el.find('.budget-wrapper.' + item.className()).append(view.render());
    }
  },
  budgetAmountView: function(record) {
    return new app.MonthlyAmountView(record)
  },
  clearedCount: function() {
    var cleared = _.filter(this.collection.models, function(arr, model) {
      debugger
      if (model.cleared) { arr.push(model) }
      return arr
    }, [])
  }
});

app.WeeklyAmountsView = app.BudgetAmountsView.extend({
  template: _.template($('#weekly-template').html()),
  id: 'weekly-amounts',
  initialize: function(dateParams) {
    this.dateParams = dateParams
    this.collection = app.WeeklyAmounts;
    this.listenTo(this.collection, 'reset', this.renderItems);
    _.bindAll(this, 'renderItem')
    this.$el.html(this.template());
  },
  render: function() {
    this.collection.fetch({reset: true, data: this.dateParams, processData: true})
    return this.$el;
  },
  renderItem: function(item) {
    var view = this.budgetAmountView(item)
    this.$el.find('.budget-wrapper.' + item.className()).append(view.render());
  },
  budgetAmountView: function(record) {
    return new app.WeeklyAmountView(record)
  }
});
