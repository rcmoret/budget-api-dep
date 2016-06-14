var app = app || {};

app.DiscretionaryView = Backbone.View.extend({
  template: _.template($('#budget-amount-template').html()),
  initialize: function() {
    this.model = new app.Discretionary();
    _.bindAll(this, 'updateDiscretionary')
    this.listenTo(app.MonthlyAmounts, 'fetch', this.rerender)
  },
  render: function() {
    this.model.fetch({
      success: this.updateDiscretionary
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
  }
})
