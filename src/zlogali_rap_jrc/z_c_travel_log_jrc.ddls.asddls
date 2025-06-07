@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Consumption - Travel'

@Metadata.allowExtensions: true

@Search.searchable: true

define root view entity Z_C_TRAVEL_LOG_jrc
//  provider contract transactional_query
  as projection on Z_I_TRAVEL_LOG_JRC

{
      @Search.defaultSearchElement: true
  key travel_id          as TravelID,

      @ObjectModel.text.element: [ 'AgencyName' ]
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [ { entity: { name:    '/DMO/I_Agency',
                                                  element: 'AgencyID' } } ]
      agency_id          as AgencyID,

      _Agency.Name       as AgencyName,

      @ObjectModel.text.element: [ 'CustomerName' ]
      @Consumption.valueHelpDefinition: [ { entity: { name:    '/DMO/I_Customer',
                                                  element: 'CustomerID' } } ]
      @Search.defaultSearchElement: true
      customer_id        as CustomerID,

      _Customer.LastName as CustomerName,
      begin_date         as BeginDate,
      end_date           as EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee        as BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price        as TotalPrice,

      @Semantics.currencyCode: true
      @Consumption.valueHelpDefinition: [ { entity: { name:    'I_Currency',
                                                  element: 'Currency' } } ]
      currency_code      as CurrencyCode,

      overall_status     as TravelStatus,
      description        as Description,
      last_changed_at    as LastChangedAt,
      /* Associations */
      _Booking : redirected to composition child Z_c_BOOKING_LOG_JRC,

      _Agency,
      _Currency,
      _Customer
}
