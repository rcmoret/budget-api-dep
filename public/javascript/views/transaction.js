var app = app || {};

app.TransactionView = Backbone.View.extend({
  template: _.template( $('#transaction-template').html() ),
  subTemplate: _.template( $('#subtransaction-template').html() ),
  events: {
    'click .editable span': 'toggleInput',
    'blur .primary .editable input': 'updateTransaction',
    'keyup .primary .editable input': 'updateTransaction',
    'click .primary a.items ': 'renderSelect',
    'blur .primary select': 'updateItems',
    'click i.fa-chevron-right': 'renderSubtransctions',
    'blur .subtransaction .editable input': 'updateSubTransaction',
    'keyup .subtransaction .editable input': 'updateSubTransaction',
    'click i.fa-chevron-down': 'collapseSubtransctions'
  },
  initialize: function(transaction, balance) {
    this.model = transaction;
    this.listenTo(app.ActiveItems, 'reset', this.populateSelect);
    this.balance = balance
  },
  description: function() {
    return this.model.get('description');
  },
  displayAttrs: function(balance) {
    return _.extendOwn(this.model.attributes, {
      displayDescription: this.model.displayDescription(),
      budgetItems: this.model.items(),
      clear_date: this.model.displayDate(),
      balance: this.balance,
    })
  },
  render: function(expanded = false) {
    this.$el.html(this.template(this.displayAttrs()));
    if (!_.isEmpty(this.model.subtransactions())) {
      this.$el.find('.amount').removeClass('editable')
      this.$el.find('.budget-items a').removeClass('items')
      this.$el.append(this.subtransactionsEl());
      if (expanded) {
        this.renderSubtransctions();
      }
    }
    return this.$el;
  },
  subtransactionsEl: function() {
    return this.subTemplate({subtransactions: this.model.subtransactions()})
  },
  toggleInput: function(e) {
    var el = $(e.toElement).parent()
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
      el.html($('<span>' + el.data('value') + '</span>'))
      return
    } else if ((e.type === 'keyup' && e.keyCode == ENTER_KEY) || e.type == 'focusout') {
      var input = this.$el.find('.primary.transaction input')
      this.model.set($(input).attr('name'), $(input).val())
      if (_.isEmpty(this.model.changed)) {
        var el = $(e.target).parent();
        el.html('');
        el.html($('<span>' + el.data('value') + '</span>'))
      } else {
        this.model.save()
      }
    }
  },
  renderSelect: function(e) {
    var el = $(e.toElement).parents('.budget-items')
    var data = el.data()
    el.html('')
    el.html(this.selectInput(data))
    el.find('select').focus()
    app.ActiveItems.fetch({reset: true})
  },
  populateSelect: function() {
    _.each(app.ActiveItems.models, function(item) {
      this.$el.find('select').append(this.optionEl(item))
    }, this)
  },
  selectInput: function(data) {
    return $("<select name='monthly_amount_id'><option value='' disabled selected></option></select>")
  },
  optionEl: function(item) {
    opt =  '<option value="' + item.id + '">'
    opt += (item.get('name') + ' $' + parseFloat(item.get('remaining')).toFixed(2))
    opt += '</option>'
    return $(opt)
  },
  updateItems: function(e) {
    var value = e.target.value === '' ? null : e.target.value
    this.model.update({monthly_amount_id: value}, {save: true})
  },
  renderSubtransctions: function() {
    this.$el.toggleClass('expanded')
    this.$el.find('i.fa.fa-chevron-right').addClass('fa-chevron-down')
    this.$el.find('i.fa.fa-chevron-right').removeClass('fa-chevron-right')
    this.$el.find('.subtransaction').removeClass('collapsed')
  },
  collapseSubtransctions: function() {
    this.$el.toggleClass('expanded')
    this.$el.find('i.fa.fa-chevron-down').addClass('fa-chevron-right')
    this.$el.find('i.fa.fa-chevron-down').removeClass('fa-chevron-down')
    this.$el.find('.subtransaction').addClass('collapsed')
  },
  updateSubTransaction: function(e) {
    if (e.type === 'keyup' && e.keyCode === ESC_KEY) {
      var el = $(e.target).parent();
      el.html('');
      el.html($('<span>' + el.data('value') + '</span>'))
      return
    } else if ((e.type === 'keyup' && e.keyCode == ENTER_KEY) || e.type == 'focusout') {
      var el = $(e.target.closest('.subtransaction'))
      var newSubAttrs = this.model.get('subtransactions_attributes')
      newSubAttrs[el.data('id')][e.target.name] = e.target.value
      this.model.set('subtransactions_attributes', newSubAttrs)
      this.model.save()
    }
  }
});
