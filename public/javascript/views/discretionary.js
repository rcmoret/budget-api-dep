var app = app || {};

app.DiscretionaryView = Backbone.View.extend({
  template: _.template($('#discretionary-template').html()),
  events: {
    'click i.fa-caret-right': 'toggleDetail',
    'click i.fa-caret-down': 'toggleDetail',
  },
  initialize: function() {
    this.model = new app.Discretionary();
    _.bindAll(this, 'updateDiscretionary')
    this.listenTo(app.MonthlyAmounts, 'change', this.render)
    this.listenTo(app.WeeklyAmounts, 'change', this.render)
    this.listenTo(app.MonthlyAmounts, 'reset', this.render)
    this.listenTo(this.model.transactions, 'reset', this.addTransactions)
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
  updateDiscretionary: function(resp) {
    var attrs = _.extendOwn(resp.attributes, { deletable: false })
    this.$el.html(this.template(attrs));
    this.$el.find('.editable').removeClass('editable')
  },
  toggleDetail: function() {
    this.$el.toggleClass('show-detail');
    this.$el.find('.transactions').toggleClass('hidden')
    this.$el.find('.remaining .label span').toggleClass('hidden');
    this.$el.find('i.fa').toggleClass('fa-caret-right')
    this.$el.find('i.fa').toggleClass('fa-caret-down')
    this.$el.find('.detail').toggleClass('hidden')
    if (this.$el.hasClass('show-detail')) {
      this.model.transactions.fetch({reset: true})
    } else {
      this.$el.find('.budget-amount-transaction:not(:first)').html('')
    }
    this.$el.find('.budgeted, .spent').slideToggle();
  },
  addTransactions: function(data) {
    _.each(data.models, function(transaction) {
      var tview = new app.BudgetAmountTransactionView(transaction)
      this.$el.find('.transactions').append(tview.render())
    }, this)
  },
})
