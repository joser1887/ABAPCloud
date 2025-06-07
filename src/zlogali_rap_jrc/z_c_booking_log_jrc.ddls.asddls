@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Consumption - Booking'

@Metadata.allowExtensions: true

define view entity Z_c_BOOKING_LOG_JRC
  as projection on Z_I_BOOKING_LOG_JRC

{
  key travel_id      as TravelID,
  key booking_id     as BookingID,

      booking_date   as BookingDate,
      customer_id    as CustomerID,

      @ObjectModel.text.element: [ 'CarrierName' ]
      carrier_id     as CarrierID,

      _Carrier.Name  as CarrierName,
      connection_id  as ConnectionID,
      flight_date    as FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price   as FlightPrice,

      @Semantics.currencyCode: true
      currency_code  as CurrencyCode,

      booking_status as BookingStatus,
      last_change_at as LastChangedAt,
      /* Associations */
      _Travel : redirected to parent Z_C_TRAVEL_LOG_jrc,
      _BookingSupplement : redirected to composition child Z_C_BOOKSUPPL_LOG_JRC,

      _Carrier,
      _Connection,
      _Customer
}
