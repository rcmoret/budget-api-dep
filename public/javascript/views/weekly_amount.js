var app = app || {};

app.WeeklyAmountsView = Backbone.View.extend({
  el: 'ul#weekly-amounts-list',
  initialize: function() {
    this.collection = app.WeeklyAmounts;
    this.listenTo(this.collection, 'reset', this.render);
  },
  render: function() {
    this.$el.html('');
    this.collection.each(function(weeklyAmount) {
      var view = new app.WeeklyAmountView(weeklyAmount);
      this.$el.append(view.render());
    },
    this);
  }
});

app.WeeklyAmountView = Backbone.View.extend({
  template: _.template( $('#weekly-amount-template').html() ),
  id: function() {
    this.model.id
  },
  events: { },
  initialize: function(weeklyAmount) {
    this.model = weeklyAmount;
    this.$el.html(this.template(this.model.attributes));
  },
  render: function() {
    return this.$el;
  }
});
