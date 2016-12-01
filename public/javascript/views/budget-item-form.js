var app = app || {};

app.BudgetItemFormView = Backbone.View.extend({
  template: _.template($('#budget-item-form').html()),
  events: {
    'submit form': 'addItem',
  },
  initialize: function(itemName) {
    this.itemName = itemName
  },
  render: function() {
    this.$el.html('')
    this.$el.html(this.template({name: this.itemName}))
    return this.$el
  },
  addItem: function(e) {
    e.preventDefault()
    var attrs = _.reduce($(e.target).serializeArray(), function(memo, attr) {
      memo[attr.name] = attr.value
      return memo
    }, {})
    var newItem = new app.BudgetItem()
    newItem.save(attrs, {
      success: function(data) {},
      error: function(data, msg) {
        console.log(msg['responseText'])
      }
    })
  }
})
