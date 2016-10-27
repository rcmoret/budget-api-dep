var app = app || {};

app.BudgetItemView = Backbone.View.extend({
  tagName: 'div',
  className: 'result',
  template: _.template($('#budget-item-forselect-template').html()),
  initialize: function(item) {
    this.model = item
    this.attributes = item.attributes
    this.month = this.month()
    this.year = this.year()
    this.listenTo(this.model, 'reveal', this.reveal)
    this.listenTo(this.model, 'removeAsResult', this.removeAsResult)
    this.listenTo(this.model, 'rerender', this.rerender)
  },
  events: {
    'click .editable': 'renderEdit',
    'blur input.item': 'updateItem',
    'keyup input.item': 'updateItem',
    'click i.fa-plus': 'renderAmtForm',
    'click i.fa-sort-down': 'removeForm'
  },
  render: function() {
    this.$el.html(this.template(this.model.attributes))
    $('#item-list-hidden').append(this.$el)
  },
  rerender: function() {
    this.$el.html(this.template(this.model.attributes))
    if (this.model.hasCurrentWeeklyAmount()) {
      this.$el.find('.name').addClass('strikethru')
    }
  },
  isDisplayed: function() {
    return this.$el.parent().attr('id') !== 'item-list-hidden'
  },
  reveal: function() {
    if (this.model.hasCurrentWeeklyAmount()) {
      this.$el.find('.name').addClass('strikethru')
      this.$el.find('i').removeClass('fa-plus')
    }
    if (!this.isDisplayed()) {
      $('#item-results').append(this.$el)
    }
  },
  removeAsResult: function() {
    if (this.isDisplayed()) {
      $('#item-list-hidden').append(this.$el)
    }
  },
  renderEdit: function(e) {
    var el = $(e.toElement)
    var data = el.data()
    el.html('')
    el.html(this.textInput(data.name, data.value))
    this.$el.find('input').addClass('item')
    this.$el.find('input').focus()
  },
  textInput: function(name, val) {
    markup = $('<input name="' + name + '" type="text"/>')
    markup.val(val)
    return markup
  },
  updateItem: function(e) {
    if ((e.type === 'keyup' && e.keyCode === ENTER_KEY) || e.type === 'focusout') {
      var name = e.target.name
      var val =  e.target.value
      var attrs = {}
      this.model.set(name, val)
      this.model.save()
      this.model.trigger('rerender')
    }
  },
  renderAmtForm: function(e) {
    var el = $(e.toElement.parentElement).closest('.result')
    el.find('.right-icon i.fa-plus').removeClass('fa-plus')
    el.find('.right-icon i.fa').addClass('fa-sort-down')
    var newAmount = new app.BudgetAmount({
      month: (this.month + '|' + this.year),
      item_id: el.attr('id'), name: el.attr('name'),
      amount: el.attr('default_amount')
    })
    var formView = new app.BudgetAmountFormView(newAmount, this)
    el.find('.right-icon').after(formView.render())
    var formInput = formView.$el.find('input')
    formInput.val(el.attr('default_amount')).focus()
  },
  removeForm: function(e) {
    var el = $(e.toElement.parentElement).closest('.result')
    el.find('.right-icon i.fa').removeClass('fa-sort-down')
    el.find('.right-icon i.fa').addClass('fa-plus')
    this.$el.find('.budget-amount-form').remove()
  },
  month: function() {
    var month = app.dateParams.month || (new Date).getMonth() + 1
    return (month < 10 ? '0' + month : month)
  },
  year: function() {
    return (app.dateParams.year || (new Date).getFullYear())
  },
})
