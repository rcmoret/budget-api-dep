var app = app || {};

app.DiscretionaryView = Backbone.View.extend({
  template: _.template($('#discretionary-template').html()),
  initialize: function() {
    this.model = new app.Discretionary();
    _.bindAll(this, 'updateDiscretionary')
    this.listenTo(app.MonthlyAmounts, 'change', this.render)
    this.listenTo(app.WeeklyAmounts, 'change', this.render)
    this.listenTo(app.MonthlyAmounts, 'reset', this.render)
  },
  render: function() {
    this.model.fetch({
      success: this.updateDiscretionary,
      data: app.dateParams,
      processData: true
    })
    $('#discretionary').html(this.$el)
    return this.$el
  },
  events: {
    'click i.fa-caret-right': 'toggleDetail',
    'click i.fa-caret-down': 'toggleDetail',
  },
  updateDiscretionary: function(resp) {
    var spent = (resp.attributes['amount'] - resp.attributes['remaining'])
    var attrs = _.extendOwn(resp.attributes, { deletable: false, spent: spent })
    this.$el.html(this.template(attrs));
    this.$el.find('.editable').removeClass('editable')
  },
  toggleDetail: function() {
    this.$el.toggleClass('show-detail');
    this.$el.find('.remaining .label span').toggleClass('hidden');
    this.$el.find('i.fa').toggleClass('fa-caret-right')
    this.$el.find('i.fa').toggleClass('fa-caret-down')
    this.$el.find('.budgeted, .spent').slideToggle();
  },
})
