var app = app || {};

app.monthSelectView = Backbone.View.extend({
  initialize: function(accountId) {
    this.accountId = accountId
    this.collection = new app.SelectableMonths(accountId)
  },

  render: function() {
    this.collection.fetch({
      success: function(data) {
        _.each(data.models, function(dateObj) {
          var template = _.template($('#selectable-month-template').html())
          $('select#select-month').append(template(dateObj.attributes))
        })
      }
    })
  }
});
