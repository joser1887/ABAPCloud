@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Consumption - Travel Aprobal'

@Metadata.allowExtensions: true

define root view entity Z_C_ATRAVEL_LOG_JRC
  as projection on Z_I_TRAVEL_LOG_JRC

{
  key travel_id          as TravelID,

      @ObjectModel.text.element: [ 'AgencyName' ]
      agency_id          as AgencyID,

      _Agency.Name       as AgencyName,

      @ObjectModel.text.element: [ 'CustomerName' ]
      customer_id        as CustomerID,

      _Customer.LastName as CustomerName,
      begin_date         as BeginDate,
      end_date           as EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee        as BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price        as TotalPrice,

      currency_code      as CurrencyCode,
      overall_status     as TravelStatus,
      description        as Description,
      last_changed_at    as LastChangedAt,
      /* Associations */
      _Booking : redirected to composition child Z_C_ABOOKING_LOG_JRC,

      _Agency,
      _Customer
}
