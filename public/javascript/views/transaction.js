var app = app || {};

app.TransactionView = Backbone.View.extend({
  template: _.template( $('#transaction-template').html() ),
  subTemplate: _.template( $('#subtransaction-template').html() ),
  events: {
    'click .editable': 'toggleInput',
    'blur .editable input': 'updateTransaction',
    'keyup .editable input': 'updateTransaction',
    'click a.items ': 'renderSelect',
    'blur select': 'updateItems',
    'click i.fa-chevron-right': 'renderSubtransctions',
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
    if (this.model.subtransactions().length > 0) {
      this.$el.find('.amount').removeClass('editable')
      this.$el.find('.budget-items a').removeClass('items')
      this.$el.append(this.subtransactionsEl());
      if (expanded) {
        this.$el.find('.left-icon i').removeClass('fa-chevron-right')
        this.$el.find('.left-icon i').addClass('fa-chevron-down')
        this.$el.find('.subtransaction').removeClass('collapsed')
      }
    }
    return this.$el;
  },
  subtransactionsEl: function() {
    return this.subTemplate({subtransactions: this.model.subtransactions()})
  },
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
      _.each(this.$el.find('.primary.transaction input'), function(input) {
        if ($(input).val() !== '') {
          attrs[$(input).attr('name')] = $(input).val()
        }
      });
      attrs['subtransactions_attributes'] = this.subtransactionAttributes()
      this.model.update(attrs, {save: true})
    }
  },
  subtransactionAttributes: function() {
    return _.map(this.$el.find('.subtransaction'), function(sub) {
      subAttrs = { id: $(sub).data('id') }
      _.each($(sub).find('input'), function(input) {
        if ($(input).val() !== '') {
          subAttrs[$(input).attr('name')] = $(input).val()
        }
       })
      return subAttrs
    })
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
  }
});
