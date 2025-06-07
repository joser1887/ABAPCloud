@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Consumption - Travel Aprobal'

@Metadata.allowExtensions: true

@Search.searchable: true

define root view entity Z_C_ATRAVEL_LOG_JRC
  provider contract transactional_query
  as projection on Z_I_TRAVEL_LOG_JRC

{
      @Search.defaultSearchElement: true
  key travel_id          as TravelID,

      @Consumption.valueHelpDefinition: [ { entity: { name:    '/DMO/I_Agency',
                                                      element: 'AgencyID' } } ]
      @ObjectModel.text.element: [ 'AgencyName' ]
      @Search.defaultSearchElement: true
      agency_id          as AgencyID,

      _Agency.Name       as AgencyName,

      @Consumption.valueHelpDefinition: [ { entity: { name:    '/DMO/I_Customer',
                                                      element: 'CustomerID' } } ]
      @ObjectModel.text.element: [ 'CustomerName' ]
      @Search.defaultSearchElement: true
      customer_id        as CustomerID,

      _Customer.LastName as CustomerName,
      begin_date         as BeginDate,
      end_date           as EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee        as BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price        as TotalPrice,

      @Consumption.valueHelpDefinition: [ { entity: { name:    'I_Currency',
                                                      element: 'Currency' } } ]
      currency_code      as CurrencyCode,
      @EndUserText.label: 'Overall Status'
      overall_status     as TravelStatus,
      description        as Description,
      last_changed_at    as LastChangedAt,
      /* Associations */
      _Booking : redirected to composition child Z_C_ABOOKING_LOG_JRC,

      _Agency,
      _Customer
}
