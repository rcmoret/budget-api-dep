Budget API
==========

## Resources
* Accounts
* Transactions
* Budget::Categories
* Budget::Items
* Budget::Intervals
* Budget::CategoryMaturityIntervals
* Transfer::Entries
* Transfer::Details
* Icons

## Endpoints
### Accounts

| HTTP Verb       | Endpoint                        | Expected return                      |
| --------------- | -----------------               | ------------------------------------ |
| GET (index)     | /accounts                       | all active (not scoped accounts)     |
| GET (show)      | /accounts/:id                   | 200 + resource / 404                 |
| POST            | /accounts                       | 201 + resource / 404, 422            |
| PUT             | /accounts/:id                   | 200 + resource / 404, 422            |
| DELETE          | /accounts/:id                   | 200 / 404, 422                       |

### Transactions

| HTTP Verb     | Endpoint                       | Expected return                                   |
| ------------- | ---------------------------    | ----------------                                  |
| GET (index)   | /accounts/:id/transactions     | collection of transaction resources plus metadata |
| GET (show)    | /accounts/:id/transactions/:id | 200 + resource / 404                              |
| POST          | /accounts/:id/                 | 201 + resource / 404, 422                         |
| PUT           | /accounts/:id/transactions/:id | 200 + resource / 404, 422                         |
| DELETE        | /accounts/:id/transactions/:id | 204 / 404, 422                                    |

### Budget
#### Categories
| HTTP Verb   | Endpoint               | Expected return           |
| ---------   | --------               | ---------------           |
| GET (index) | /budget/categories     | all active catgories      |
| POST        | /budget/categories     | 201 + resource / 404, 422 |
| PUT         | /budget/categories/:id | 200 + resource / 404, 422 |
| DELETE      | /budget/categories/:id | 204 / 404, 422            |

#### Items
| HTTP Verb   | Endpoint                                               | Expected return                                   |
| ---------   | --------                                               | ---------------                                   |
| GET (index) | /budget/items                                          | collection of budget item resources and metadata  |
| POST        | /budget/categories/:category_id/items                  | 201 + resource / 404, 422                         |
| GET         | /budget/categories/:category_id/items/:id              | 200 + resource / 404                              |
| PUT         | /budget/categories/:category_id/items/:id              | 200 + resource / 404, 422                         |
| DELETE      | /budget/categories/:category_id/items/:id              | 204 / 404, 422                                    |
| GET         | /budget/categories/:category_id/items/:id/transactions | transactions collection                           |

#### Discretionary
| HTTP Verb | Endpoint                           | Expected return                                          |
| --------- | --------                           | ---------------                                          |
| GET       | /budget/discretionary/transactions | collection of discretionary transactions for given month |

### Transfers
| HTTP Verb   | Endpoint       | Expected return                        |
| ---------   | --------       | ---------------                        |
| GET (index) | /transfers     | collection of transfers, plus metadata |
| POST        | /transfers     | 201 + resource / 404, 422              |
| DELETE      | /transfers/:id | 200 / 404, 422                         |

### Icons
| HTTP Verb   | Endpoint   | Expected return           |
| ---------   | --------   | ---------------           |
| GET (index) | /icons     | collection of icons       |
| GET (show)  | /icons/:id | 200 + resource / 404, 422 |
| POST        | /icons     | 201 + resource / 404, 422 |
| PUT         | /icons/:id | 200 + resource / 404, 422 |
| DELETE      | /icons/:id | 204 / 404, 422            |

### Budget Category Maturity Intervals
| HTTP Verb    | Endpoint                                                 | Expexted return                  |
| --------     | --------                                                 | ---------------                  |
| GET (index)  | /budget/categories/:catgory_id/maturity_intervals        | collection of maturity intervals |
| POST         | /budget/categories/#{category.id}/maturity_intervals     | 201 + resource / 404, 422        |
| PUT          | /budget/categories/#{category.id}/maturity_intervals/:id | 200 + resource / 404, 422        |
| DELETE       | /budget/categories/#{category.id}/maturity_intervals/:id | 204 / 404, 422                   |

### Intervals
| HTTP Verb | Endpoint               | Expected return |
| --------- | ---------------------- | --------------- |
| PUT       | /interval/:month/:year | 200 + resource  |

## ERD
![Database Schema](./docs/budget-erd-v3.0.png)

## JSON Representations
### Accounts

#### Index
```
[
    {
        "id": 1,
        "name": "Checking",
        "cash_flow": true,
        "priority": 1,
        "archived_at": null,
        "created_at": "2019-01-02T23:59:28.473Z",
        "updated_at": "2019-02-22T05:49:22.399Z",
        "balance": 77126
    },
    ...
]
```

#### Show
```
  {
      "id": 1,
      "name": "Checking",
      "cash_flow": true,
      "priority": 1,
      "archived_at": null,
      "created_at": "2019-01-02T23:59:28.473Z",
      "updated_at": "2019-02-22T05:49:22.399Z",
      "balance": 77126
  }
```

### Transactions
#### Index

```
{
  "metadata": {
    "date_range": [
      "2019-03-01",
      "2019-03-31"
      ],
    "prior_balance": 30784,
    "query_options": {
     "account_id": "1",
     "include_pending": true
    }
  },

  "transactions": [
    {
      "id": 12236,
      "description": "Transfer from Aspiration",
      "check_number": null,
      "clearance_date": null,
      "account_id": 12,
      "notes": null,
      "budget_exclusion": null,
      "transfer_id": 110,
      "receipt": null,
      "created_at": "2020-01-03T15: 02: 01.502Z",
      "updated_at": "2020-01-03T15: 02: 01.507Z",
      "account_name": "Student Loan",
      "details":
        [
          {
            "id": 13066,
            "budget_category": null,
            "budget_item_id": null,
            "amount": 5500,
            "icon_class_name": null
          }
        ]
    },
    ...
  ]
}
```

#### Resource
This resource will be returned after PUT and POST requests and for the GET (show) route
```
{
  "id": 12202,
  "description": "TTB Merch",
  "check_number": "",
  "clearance_date": "2019-07-26",
  "account_id": 11,
  "notes": null,
  "budget_exclusion": false,
  "transfer_id": null,
  "receipt": null,
  "created_at": "2019-07-27T15: 34: 13.294Z",
  "updated_at": "2019-07-27T15: 34: 13.294Z",
  "account_name": "Cash on Hand",
  "details": [
    {
      "id": 13026,
      "budget_category": "Vacation",
      "budget_item_id": 2652,
      "amount": -6500,
      "icon_class_name": "fas fa-plane-departure"
    },
    {
      "id": 13025,
      "budget_category": "Clothes and Shoes",
      "budget_item_id": 2643,
      "amount": -3000,
      "icon_class_name": "fas fa-tshirt"
    }
  ]
}
```

This version will be returned for the show route
```
{
  "id": 9446,
  "description": "",
  "amount": -800,
  "clearance_date": "2019-10-11",
  "check_number": null,
  "account_id": 17,
  "budget_item_id": 2929,
  "primary_transaction_id": 9445,
  "notes": null,
  "receipt": null,
  "budget_exclusion": false,
  "transfer_id": null,
  "created_at": "2019-10-13T19:22:57.882Z",
  "updated_at": "2019-10-13T19:22:57.882Z",
  "account_name": "Aspiration (ck)"
}
```

### Budget
#### Categories

##### Index
```
[
  {
    "id": 2,
    "accrual": true,
    "name": "Grocery",
    "expense": true,
    "monthly": false,
    "default_amount": -10000,
    "icon_id": null,
    "icon_class_name": null
  },
]
```

##### Resource
```
{
  "id": 2,
  "name": "Grocery",
  "expense": true,
  "monthly": false,
  "default_amount": -10000,
  "icon_id": null,
  "icon_class_name": null
}
```
There is no show route per se, but this resource will be returned after PUT and POST requests

#### Items
##### Index
```
{
  "metadata": {
    "spent": 68417,
    "balance": 108818,
    "days_remaining": 30,
    "total_days": 31,
    "month": 3,
    "year": 2019
    "is_set_up": true,
    "is_closed_out": false,
  },
  "collection": [
    {
      "id": 26,
      "month": 3,
      "year": 2019,
      "accrual": false,
      "amount": -9000,
      "budget_category_id": 12,
      "budget_interval_id": 22,
      "created_at": "2019-02-15T03:48:47.289Z",
      "updated_at": "2019-02-15T03:48:47.289Z",
      "name": "gas",
      "expense": true,
      "monthly": false,
      "icon_class_name": null,
      "icon_name": null,
      "transaction_count": 0,
      "spent": 0
    }
  ]
}
```

##### Resource
A full version of the resource is returned after POST or PUT requests
```
{
  "id": 26,
  "month": 3,
  "year": 2019,
  "accrual": false,
  "amount": -9000,
  "budget_category_id": 12,
  "budget_interval_id": 22,
  "created_at": "2019-02-15T03:48:47.289Z",
  "updated_at": "2019-02-15T03:48:47.289Z",
  "name": "gas",
  "expense": true,
  "monthly": false,
  "icon_class_name": null,
  "icon_name": null,
  "transaction_count": 0,
  "spent": 0
}
```

##### Transactions
Get a simplified set of transactions for a budget item
```
  [
    {
      "id": 12144,
      "transaction_entry_id": 11426,
      "budget_item_id": 2278,
      "amount": -80000,
      "created_at": "2019-12-27T19: 13: 34.787Z",
      "updated_at": "2019-12-27T19: 13: 34.787Z",
      "entry_id": 11426,
      "account_id": 11,
      "clearance_date": "2019-03-22",
      "description": null,
      "budget_exclusion": false,
      "notes": null,
      "receipt": null,
      "transfer_id": null,
      "entry_created_at": "2019-03-22T16: 26: 44.367Z",
      "entry_updated_at": "2019-03-22T16: 26: 44.367Z",
      "account_name": "Cash on Hand",
      "category_name": "Rent",
      "icon_class_name": "fas fa-home"
    },
    ...
  ]
```

### Transfers

##### Resource
```
{
  "id": 110,
  "to_transaction_id": 12236,
  "from_transaction_id": 12235,
  "created_at": "2020-01-03T15: 02: 01.503Z",
  "updated_at": "2020-01-03T15: 02: 01.503Z",
  "to_transaction": {
    "id": 12236,
    "description": "Transfer from Aspiration",
    "check_number": null,
    "clearance_date": null,
    "account_id": 12,
    "notes": null,
    "budget_exclusion": null,
    "transfer_id": 110,
    "receipt": null,
    "created_at": "2020-01-03T15: 02: 01.502Z",
    "updated_at": "2020-01-03T15: 02: 01.507Z",
    "account_name": "Student Loan",
    "details": [
      {
        "id": 13066,
        "transaction_entry_id": 12236,
        "budget_item_id": null,
        "amount": 5500,
        "created_at": "2020-01-03T15: 02: 01.503Z",
        "updated_at": "2020-01-03T15: 02: 01.503Z"
      }
    ]
  },
  "from_transaction": {
    "id": 12235,
    "description": "Transfer to Student Loan",
    "check_number": null,
    "clearance_date": null,
    "account_id": 17,
    "notes": null,
    "budget_exclusion": null,
    "transfer_id": 110,
    "receipt": null,
    "created_at": "2020-01-03T15: 02: 01.499Z",
    "updated_at": "2020-01-03T15: 02: 01.510Z",
    "account_name": "Aspiration",
    "details": [
      {
        "id": 13065,
        "transaction_entry_id": 12235,
        "budget_item_id": null,
        "amount": -5500,
        "created_at": "2020-01-03T15: 02: 01.500Z",
        "updated_at": "2020-01-03T15: 02: 01.500Z"
      }
    ]
  }
}
```

##### Index
```
{
  "metadata": {
    "limit": 10,
    "offset": 0,
    "viewing": [
        1,
        1
    ],
    "total": 1
  },
  "transfers": [
    {
      "id": 110,
      "to_transaction_id": 12236,
      "from_transaction_id": 12235,
      "created_at": "2020-01-03T15: 02: 01.503Z",
      "updated_at": "2020-01-03T15: 02: 01.503Z",
      "to_transaction": {
        "id": 12236,
        "description": "Transfer from Aspiration",
        "check_number": null,
        "clearance_date": null,
        "account_id": 12,
        "notes": null,
        "budget_exclusion": null,
        "transfer_id": 110,
        "receipt": null,
        "created_at": "2020-01-03T15: 02: 01.502Z",
        "updated_at": "2020-01-03T15: 02: 01.507Z",
        "account_name": "Student Loan",
        "details": [
          {
            "id": 13066,
            "transaction_entry_id": 12236,
            "budget_item_id": null,
            "amount": 5500,
            "created_at": "2020-01-03T15: 02: 01.503Z",
            "updated_at": "2020-01-03T15: 02: 01.503Z"
          }
        ]
      },
      "from_transaction": {
        "id": 12235,
        "description": "Transfer to Student Loan",
        "check_number": null,
        "clearance_date": null,
        "account_id": 17,
        "notes": null,
        "budget_exclusion": null,
        "transfer_id": 110,
        "receipt": null,
        "created_at": "2020-01-03T15: 02: 01.499Z",
        "updated_at": "2020-01-03T15: 02: 01.510Z",
        "account_name": "Aspiration",
        "details": [
          {
            "id": 13065,
            "transaction_entry_id": 12235,
            "budget_item_id": null,
            "amount": -5500,
            "created_at": "2020-01-03T15: 02: 01.500Z",
            "updated_at": "2020-01-03T15: 02: 01.500Z"
          }
        ]
      }
    }
  ]
}
```

### Budget Category Maturity Intervals
#### Resource
```
{
  id: 1,
  category_id: 44,
  month: 12,
  year: 2022
}
```

### Icons
##### Index
```
[
  {
    "id": 1,
    "class_name": "fas fa-beer",
    "name": "Beer"
  },
]
```

##### Resource
```
{
  "id": 8,
  "class_name": "fas fa-subway",
  "name": "Subway"
}
```

## How it all works
### Accounts
Accounts are mostly self explanitory. This can be a regular checking account, savings, credit card etc.
There is a boolean column called `cash_flow`. This flag is set to true for things that are typcially used for daily expenses.
This flag should be set false for accounts that you expect to maintain a constant balance or you
want to budget for the change (ie a savings account you want to grow or a credit card you are trying to pay down). So, even
if you like to use your credit card for daily stuff and you religiously pay it off this would be a non-cashflow account.

### Budget Categories
Budget Categories are types of expenses and revenues. They are also categorized as weekly and monthly which provide for
a nice grouping. The default amount is a nice to have for things that stay the same or for things that are divided up
over several months. An accrual is a category that is not expected each interval. See items for more information.

### Budget Interval
Currently represents a month (month + year combination) but could be changed to be quarterly etc. An interval has many
budget items. It also contains information about set up and finalization.

### Budget Items
Budget Items are a month's instance of a budget category. They can have whatever amount (as longer expenses are <= 0 and
revenues are >= 0) is needed. Weekly and monthly can have different rules for how they are treated and how they are used
to determine information about the state of the budget. This app certainly hints at how that could be done but is not
prescriptive.

### Transaction
A transaction entry plus its associated details together constitute the concept of a transaction.

### Transaction Entry
This concept ties a lot of the other items together. This model belongs to an account and represents the high level data about
a transaction. If the transaction belongs to a non-cashflow account it can be a budget exclusion. This record maintains a
transaction's clearance date, description, notes, receipt (not currently functional) and check number.

### Transaction Detail
A transaction entry must have at least one detail. Transfers and budget exclusions may only have one detail. The
detail captures amount and budget item id. This allows for entries to have multiple budget items associated with them in a
line-item sort of way.

#### Views
Several views (with associated models) have been create to neatly present the attributes for a record plus useful supplemental
data. For transactions, there is an entry view that includes the account name, and the details (amount, budget item id, plus budget
category name and icon class name if available). The detail view merges the entry's data with the detail's and also includes the
account name. A budget item view was created that includes the item's attribute, plus data from the category, the number of assoicated
transcations, the sum of those transactions, the month and year are included from the budget interval, also the next upcoming
maturity interval is calculated.

#### Budget Exclusion
This option is available for transactions of non-cashflow accounts. This would be used for a transaction that will change
the balance of an account that will not impact the budget. This type of transaction can be used in pairs where one transaction,
which is not an exclusion is tied to a budget item (savings for example) and this transaction is a debit from one account
and the deposit into savings which is then a budget exclusion. These are also excluded from the discretionary transactions.

### Transfers
Moving money from one place to another. There is a restrictions against changing amounts when a transaction is tied to a
transfer. They also cannot have a budget_item associated. These will not appear in discretionary transactions either.
