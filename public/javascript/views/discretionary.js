var app = app || {};

app.DiscretionaryView = Backbone.View.extend({
  template: _.template($('#budget-amount-template').html()),
  initialize: function(month, year) {
    this.month = month;
    this.year = year;
    this.model = new app.Discretionary();
    _.bindAll(this, 'updateDiscretionary')
    this.listenTo(app.MonthlyAmounts, 'fetch', this.rerender)
  },
  render: function() {
    console.log(this.dateParams());
    this.model.fetch({
      success: this.updateDiscretionary,
      data: this.dateParams(),
      processData: true
    })
    return this.$el
  },
  updateDiscretionary: function(resp) {
    this.$el.html(this.template(resp.attributes));
    this.$el.find('.editable').removeClass('editable')
  },
  rerender: function(resp) {
    this.model.fetch({
      success: this.$el.html(this.template(resp.attributes))
    })
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
