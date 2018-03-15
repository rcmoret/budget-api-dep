var app = app || {};

app.BudgetSidebarView = Backbone.View.extend({
  className: 'budget-block',
  template: _.template($('#budget-sidebar').html()),
  initialize: function() {
    this.month = this.month()
    this.year = app.dateParams.year
    this.listenTo(app.ActiveMonthlyItems, 'reset', this.updateSelect)
  },
  events: {
    'change #budget-items': 'populateDefaultVal',
    // 'click span.submit': 'addBudgetAmount',
    'keyup input#budget-items': 'renderResults',
    'click span.see-more': 'renderResults',
    'click nav .tab': 'toggleItems',
    'click span.add-term': 'addItem',
    'click span.see-less': 'showLess'
  },
  showLess: function(e) {
    this.renderResults(e)
  },
  render: function() {
    this.$el.html('')
    this.$el.html(this.template({month: this.month, year: this.year}));
    app.ActiveMonthlyItems.fetch({reset: true, data: app.dateParams, processData: true})
    return this.$el
  },
  updateSelect: function() {
    _.each(app.ActiveMonthlyItems.models, function(item) {
      var itemView = new app.BudgetItemView(item)
      itemView.render()
    })
  },
  optionEl: function(item) {
    var data = 'data-amount="' + item.get('default_amount') + '"'
    var opt = $('<option ' + data + '>' + item.get('name') + '</option>')
    opt.val(item.id)
    return opt
  },
  populateDefaultVal: function(e) {
    var val = $(e.target).find('option:selected').data('amount')
    this.$el.find('input[name="amount"]').val(val)
  },
  month: function() {
    var month = this.dateParams['month'] || (new Date).getMonth() + 1
    return (month < 10 ? '0' + month : month)
  },
  year: function() {
    return (this.dateParams['year'] || (new Date).getFullYear())
  },
  renderResults: function(e) {
    this.$el.find('.result.see-more').remove()
    this.$el.find('.result.see-less').remove()
    this.$el.find('.result.add-term').remove()
    _.each(app.ActiveMonthlyItems.models, function(model) {
      model.trigger('removeAsResult')
    })
    var seeAll = $(e.toElement).hasClass('see-more')
    var items = this.fetchItems()
    if (items.length > 6 && !seeAll) {
      _.each(_.first(items, 6), function(item) {
        item.trigger('reveal')
      })
      $('#item-results').append(this.seeMoreEl())
    } else {
      _.each(items, function(item) {
        item.trigger('reveal')
      })
      if (items.length === 0 && this.searchTerm().length > 2) {
        $('#item-results').html('')
        $('#item-results').append(this.addTermEl())
      } else if (items.length > 6) {
        $('#item-results').append(this.seeLessEl())
      }
    }
  },
  searchTerm: function() {
    return $('input#budget-items').val()
  },
  fetchItems: function() {
    var tabSelected = $('nav .tab.selected').text().toLowerCase()
    if (_.isEmpty(this.searchTerm()) && _.isEmpty(tabSelected)) {
      return []
    }
    var items = app.ActiveMonthlyItems.search(this.searchTerm(), tabSelected)
    if (_.isEmpty(items.primary)) {
      return []
    }
    return items.primary.concat(items.secondary || []).concat(items.budgeted || [])
  },
  seeMoreEl: function() {
    var markup =  "<div class='result see-more'><div class='item-list-item'>"
        markup += "<span class='see-more clickable'>"
        markup += "See More Results</span></div></div>"
    return $(markup)
  },
  seeLessEl: function() {
    var markup =  "<div class='result see-less'><div class='item-list-item'>"
        markup += "<span class='see-less clickable'>"
        markup += "See Fewer Results</span></div></div>"
    return $(markup)
  },
  addTermEl: function() {
    var markup =  "<div class='result add-term'><div class='item-list-item'>"
        markup += "<span class='add-term clickable'>Add new item: "
        markup += this.searchTerm() + "?</span></div></div>"
    return $(markup)
  },
  toggleItems: function(e) {
    var el = $(e.toElement)
    el.toggleClass('selected')
    var index = ':eq(' + el.index() + ')'
    $('nav .tab').not(index).removeClass('selected')
    this.renderResults(e)
  },
  month: function() {
    var mon = String(app.dateParams.month)
    return (mon.match(/^\d{1}$/)) ? '0' + mon : mon
  },
  addItem: function(e) {
    var view = new app.BudgetItemFormView(this.searchTerm())
    $('#item-results .result').remove()
    $('#item-results').append(view.render())
  },
})
