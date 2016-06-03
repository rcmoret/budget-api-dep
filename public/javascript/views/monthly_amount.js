var app = app || {};

app.MonthlyAmountsView = Backbone.View.extend({
  el: '#monthly-amounts-list',
  initialize: function() {
    this.collection = app.MonthlyAmounts;
    this.listenTo(this.collection, 'reset', this.render);
  },
  render: function() {
    this.$el.html('');
    this.collection.each(function(monthlyAmount) {
      var view = new app.MonthlyAmountView(monthlyAmount);
      this.$el.append(view.render());
    },
    this);
  }
});

app.MonthlyAmountView = Backbone.View.extend({
  template: _.template( $('#monthly-amount-template').html() ),
  id: function() {
    this.model.id
  },
  events: { },
  initialize: function(monthlyAmount) {
    this.model = monthlyAmount;
    this.$el.html(this.template(this.model.attributes));
  },
  render: function() {
    return this.$el;
  }
});
