var app = app || {};

app.TransactionView = Backbone.View.extend({
  template: _.template( $('#transaction-template').html() ),
  subTemplate: _.template( $('#subtransaction-template').html() ),
  events: {
    'click .editable span': 'toggleInput',
    'blur .primary .editable input': 'updateTransaction',
    'keyup .primary .editable input': 'updateTransaction',
    'click a.items ': 'renderSelect',
    'blur .primary select': 'updateItems',
    'keyup .primary select': 'updateItems',
    'blur .subtransaction select': 'updateItemsViaSub',
    'keyup .subtransaction select': 'updateItemsViaSub',
    'click i.fa-chevron-right': 'renderSubtransctions',
    'blur .subtransaction .editable input': 'updateSubTransaction',
    'keyup .subtransaction .editable input': 'updateSubTransaction',
    'click i.fa-chevron-down': 'collapseSubtransctions'
  },
  initialize: function(transaction, balance) {
    this.model = transaction;
    _.bindAll(this, 'appendSelect')
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
    app.ActiveItems.fetch({
      success: this.appendSelect
    })
  },
  appendSelect: function(items) {
    _.each(items.models, function(item) {
      if (item.id !== this.model.get('monthly_amount_id')) {
        this.$el.find('select').append(this.optionEl(item));
      }
    }, this)
  },
  selectInput: function(data) {
    var select = "<select name='monthly_amount_id'><option selected value= "
    if (_.isUndefined(data['value'])) {
      select += "'' disabled>"
    } else {
      select += "'" + data['value'] + "'>"
      select += data['displayVal']
    }
    select += "</option></select>"
    return $(select)
  },
  optionEl: function(item) {
    var opt =  '<option value="' + item.id + '"'
    opt += '>'
    opt += (item.get('name') + ' $' + parseFloat(item.get('remaining')).toFixed(2))
    opt += '</option>'
    return $(opt)
  },
  updateItems: function(e) {
    if (e.type === 'keyup' && e.keyCode === ESC_KEY) {
      var el = e.target.parentElement
      $(el).html('')
      var anchor = '<a class="items">'
      if (_.isNull(this.model.get('budgetItems'))) {
        var linkText = '<i class="fa fa-list-ul" aria-hidden="true"></i>'
      } else {
        var linkText = this.model.get('budgetItems')
      }
      markup = anchor + linkText + '</a>'
      $(el).html(markup)
    } else {
      var value = e.target.value === '' ? null : e.target.value
      this.model.set({monthly_amount_id: value})
      this.model.save()
    }
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
    } else {
      var total = _.reduce(this.$el.find('.subtransaction .amount'), function(memo, el) {
        var amt = ($(el).find('input').length === 0) ? $(el).data('value') : $(el).find('input').val()
        var amount = $.isNumeric(amt) ? parseFloat(amt) : 0
        return memo += amount
      }, 0)
      this.$el.find('.primary .amount').first().text('$' + parseFloat(total).toFixed(2));
    }
  },
  updateItemsViaSub: function(e) {
    if (e.type === 'keyup' && e.keyCode === ESC_KEY) {
      var el = $(e.target).parent();
      el.html('');
      el.html($('<a class="items">' + el.data('value') + '</a>'))
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
