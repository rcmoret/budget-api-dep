var app = app || {};

app.DiscretionaryView = Backbone.View.extend({
  template: _.template($('#budget-amount-template').html()),
  initialize: function(dateParams) {
    this.dateParams = dateParams;
    this.model = new app.Discretionary();
    _.bindAll(this, 'updateDiscretionary')
    this.listenTo(app.MonthlyAmounts, 'change', this.render)
    this.listenTo(app.WeeklyAmounts, 'change', this.render)
    this.listenTo(app.MonthlyAmounts, 'reset', this.render)
  },
  render: function() {
    this.model.fetch({
      success: this.updateDiscretionary,
      data: this.dateParams,
      processData: true
    })
    $('#discretionary').html(this.$el)
    return this.$el
  },
  updateDiscretionary: function(resp) {
    this.$el.html(this.template(resp.attributes));
    this.$el.find('.editable').removeClass('editable')
  }
})
