var app = app || {};

app.TransactionView = Backbone.View.extend({
  template: _.template( $('#transaction-template').html() ),
  subTemplate: _.template( $('#subtransaction-template').html() ),
  events: {
    'click .editable': 'toggleInput',
    'blur .editable input': 'updateTransaction',
    'keyup .editable input': 'updateTransaction'
  },
  initialize: function(transaction, balance) {
    this.model = transaction;
    this.$el.html(this.template(this.displayAttrs(balance)));
  },
  description: function() {
    return this.model.get('description');
  },
  displayAttrs: function(balance) {
    return _.extendOwn(this.model.attributes, {
      displayDescription: this.model.displayDescription(),
      budgetItems: this.model.items(),
      clear_date: this.model.displayDate(),
      balance: balance,
    })
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
  subtransactionElement: $('<ul class="subtransactions collapsed"></ul>'),
  toggleInput: function(e) {
    var el = $(e.toElement)
    var data = el.data()
    el.html(this.textInput(data.name))
    el.find('input').val(data.value).focus()
  },
  textInput: function(name) {
    return $('<input type="text" name="' + name + '">');
  },
  updateTransaction: function(e) {
    if (e.type === 'keyup' && e.keyCode === ESC_KEY) {
      var el = $(e.target).parent();
      el.html('');
      el.html(el.data('value'))
      el.addClass('editable')
      return
    } else if ((e.type === 'keyup' && e.keyCode == ENTER_KEY) || e.type == 'focusout') {
      var attrs = {}
      _.each(this.$el.find('input'), function(input) {
        attrs[$(input).attr('name')] = $(input).val()
      });
      this.model.update(attrs, {save: true})
    }
  }
});
