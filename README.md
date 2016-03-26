Budget API
==========

Top Level Resources
-------------------
- Accounts
-- Transactions
- BudgetItems
-- Monthly Amounts

Endpoints
---------
*Accounts*
| HTTP Verb   | Endpoint      | Required Params | Optional Query Params | Expected return           |
| GET (index) | /accounts     | NONE            | NONE                  | all (not scoped accounts) |
| GET (show)  | /accounts/:id | :id             | NONE                  | resource as json / 404    |
| POST        | /accounts     | :name           | :cash_flow, :hsa      | 201 + resource / 400      |
| PUT         | /accounts/:id | :id             | :name, :cf, :hsa      | 200 + resource / 400      |
| DELETE      | /accounts/:id | :id             | NONE                  | 200 / 400                 |

*Transactions*
Transactions are scoped to account so all endpoints will begin: /action/:id
| HTTP Verb   | Endpoint      | Required Params | Optional Query Params | Expected return                                                               |
| GET (index) | /transactions | NONE            | :budget_month         | resources where clearance_date IN current month (or range if provided) |

JSON Representations
--------------------

*Accounts*
Index/Show
  {
    'id' : '10',
    'name' : 'first bank'
    'balance' : 10000000000.0,
    'cash_flow' : true,
    'health_savings_account' : false
  }

Account Transaction Collection
  {
    'account': {
      'id': '10',
      'name': 'first bank'
      'balance': 10000000000.0,
      'cash_flow': true,
      'health_savings_account': false
    },
    'metadata': {
      'prior_balance' : 1000000000.0,
      'date_range' : ['2016-01-01', '2016-01-31'],
      'query_params' : {
          'description' : ['Drifters'],
          'budget_item_id' : [42, 24]
      }
    },
    'transactions': [
      {
        'id': 6710,
        'description': 'Drifters', # this could be description, budget item name or defaults to 'Discretionary'
        'amount': -15.59,
        'clearance_date': '2016-01-01',
        'budget_item': 'Outings',
        'monthly_amount_id': 6710,
        'notes': 'lots more info',
        'check_number': 1067,
        'receipt_url': '/path/to/img.file',
        'qualified_medical_expense': false,
        'tax_deduction': true,
        'subtransactions':
          [
            {
              'id': 6712,
              'description': 'Food!',
              'amount': -10.0,
              'budget_item': 'Outings',
              'monthly_amount_id': 6710,
              'qualified_medical_expense': false,
              'tax_deduction': true
            },
            ... # there should always be 2 or more sub transactions
          ]
      }
    ]
  }
