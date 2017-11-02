var app = app || {};

app.BudgetAmountView = Backbone.View.extend({
  className: 'budget-amount',
  template: _.template($('#budget-amount-template').html()),
  events: {
    'click .amount.editable': 'renderAmountField',
    'blur .amount input': 'updateAmount',
    'click i.fa-trash': 'deleteAmount'
  },
  initialize: function(record) {
    this.model = record
    this.listenTo(this.model, 'rerender', this.render)
    this.listenTo(this.model, 'toggleShow', this.toggleShow)
    this.listenTo(this.model.transactions, 'reset', this.addTransactions)
  },
  textInput: function(name) {
    return $('<input type="text" name="' + name + '">');
  },
  addTransactions: function(data) {
    _.each(data.models, function(transaction) {
      var tview = new app.BudgetAmountTransactionView(transaction)
      this.$el.find('.transactions').append(tview.render())
    }, this)
  },
  deleteAmount: function(e) {
    var confirmation = confirm('Are you sure you want to remove ' + this.model.get('name') + '?')
    if(confirmation) {
      this.model.destroy()
      this.remove()
      this.collection.trigger('change')
    }
  }
});

app.MonthlyAmountView = app.BudgetAmountView.extend({
  events: function(){
    return _.extend({}, app.BudgetAmountView.prototype.events, {
      'keyup .amount input': 'updateAmount'
    })
  },
  render: function() {
    this.$el.html('')
    this.$el.html(this.template(this.model.attributes))
    this.$el.find('.amount').addClass('editable')
    return this.$el
  },
  renderAmountField: function(e) {
    var el = $(e.toElement).parent()
    var data = el.data()
    el.removeClass('editable')
    el.html(this.textInput(data.name))
    el.find('input').val(data.value).focus()
  },
  updateAmount: function(e) {
    if (e.type === 'keyup' && e.keyCode === ESC_KEY) {
      var el = $(e.target).parent();
      el.html('');
      el.html(el.data('value'))
      el.addClass('editable')
      return
    } else if ((e.type === 'keyup' && e.keyCode == ENTER_KEY) || e.type == 'focusout') {
      var params = { amount: e.target.value }
      this.model.save(params, {
        success: function(data) {
          data.trigger('rerender')
        }
      })
    }
  },
  toggleShow: function() {
    if (this.$el.parent().hasClass('cleared')) {
      $('#monthly-amounts .budget-wrapper.' + this.model.className()).append(this.$el)
    } else {
      $('#monthly-amounts .budget-wrapper.cleared').append(this.$el)
    }
  }
});

app.WeeklyAmountView = app.BudgetAmountView.extend({
  template: _.template($('#detail-template').html()),
  events: function(){
    return _.extend({}, app.BudgetAmountView.prototype.events, {
      'click i.fa-caret-right': 'toggleDetail',
      'click i.fa-caret-down': 'toggleDetail',
      'keyup .amount input': 'updateAmount',
      'click .clickable': 'renderAmountField'
    })
  },
  toggleDetail: function() {
    this.$el.toggleClass('show-detail');
    this.$el.find('.transactions').toggleClass('hidden')
    this.$el.find('.remaining .label span').toggleClass('hidden');
    this.$el.find('i.fa').toggleClass('fa-caret-right')
    this.$el.find('i.fa').toggleClass('fa-caret-down')
    this.$el.find('.budgeted, .spent').slideToggle();
    if (this.$el.hasClass('show-detail')) {
      this.model.transactions.fetch({reset: true})
    } else {
      this.$el.find('.budget-amount-transaction:not(:first)').html('')
    }
  },
  detailAttributes: function() {
    return _.extendOwn(this.model.attributes, { spent: this.model.spent() })
  },
  render: function() {
    this.$el.html('')
    this.$el.html(this.template(this.model.attributes))
    if (this.$el.hasClass('show-detail')) {
      this.$el.find('.budgeted, .spent').css('display', 'inline-block')
      this.$el.find('.hidden').removeClass('hidden')
      this.$el.find('i.fa').toggleClass('fa-caret-right')
      this.$el.find('i.fa').toggleClass('fa-caret-down')
    }
    return this.$el
  },
  renderAmountField: function(e) {
    var data = this.$el.find('.editable.amount').data()
    if (!this.$el.hasClass('show-detail')) {
      this.toggleDetail()
    }
    this.$el.find('.editable.amount').html('')
    this.$el.find('.editable.amount').html(this.textInput(data.name))
    this.$el.find('.editable.amount input').val(data.value).focus()
    this.$el.find('.amount').removeClass('editable')
  },
  updateAmount: function(e) {
    if (e.type === 'keyup' && e.keyCode === ESC_KEY) {
      var el = $(e.target).parent();
      el.html('');
      el.html(el.data('value'))
      return
    } else if ((e.type === 'keyup' && e.keyCode == ENTER_KEY) || e.type == 'focusout') {
      var params = { amount: e.target.value }
      this.model.save(params, {
        success: function(data) {
          data.trigger('rerender')
        }
      })
    } else {
      this.updateCalculations(e)
    }
  },
  updateCalculations: function(e) {
    var budgeted = parseFloat(e.target.value)
    var spent = this.$el.find('.underlined').data('spent')
    var remaining = Math.abs(budgeted - spent)
    this.$el.find('.remaining.amount').html('$' + remaining.toFixed(2))
  }
})
