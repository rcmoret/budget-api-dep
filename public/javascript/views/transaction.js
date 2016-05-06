var app = app || {};

app.TransactionView = Backbone.View.extend({
  template: _.template( $('#transaction-template').html() ),
  subTemplate: _.template( $('#subtransaction-template').html() ),
  events: {
    'click .description': 'toggleField',
    'blur .description input': 'updateDescription'
  },
  initialize: function(transaction, balance) {
    this.model = transaction;
    this.$el.html(this.template(this.model.displayAttrs(balance)));
  },
  description: function() {
    return this.model.get('description');
  },
  render: function() {
    if (this.model.subtransactions().length > 0) {
      this.$el.find('.transaction').append(this.subtransactionElement());
      _.each(this.model.subtransactions(), function(sub) {
        this.$el.find('ul.subtransactions').append(this.subTemplate(sub));
      }, this);
    }
    return this.$el;
  },
  subtransactionElement: function() {
    return $('<ul class="subtransactions collapsed"></ul>')
  },
  descriptionEl: function() {
    return this.$el.find('.description')
  },
  toggleField: function(e) {
    if (this.descriptionFieldVisible()) {
      this.descriptionField().focus();
    } else {
      this.descriptionEl().html(this.descriptionField());
      this.descriptionField().val(this.description()).focus();
    }
  },
  descriptionFieldVisible: function() {
    return this.descriptionEl().find('input').length > 0
  },
  descriptionField: function() {
    if (this.descriptionFieldVisible()) {
      return this.descriptionEl().find('input')
    } else {
      return $('<input type="text" value="">')
    }
  },
  updateDescription: function() {
    if (this.description() === this.descriptionField().val()) {
      this.descriptionEl().html(this.description());
    } else {
      this.model.update({description: this.descriptionField().val()});
    }
  },
});
