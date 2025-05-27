@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AbapCatalog.sqlViewName: 'ZVBOOK_LOG_JRC'

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Interface - Booking'

define view Z_I_BOOKING_LOG_JRC
  as select from zbooking_log_jrc as Booking

  composition [0..*] of Z_I_BOOKSUPPL_LOG_JRC as _BookingSupplement
  association to parent Z_I_TRAVEL_LOG_JRC as _Travel on $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Customer as _Customer on $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier as _Carrier on $projection.CarrierId = _Carrier.AirlineID
  association [1..*] to /DMO/I_Connection as _Connection on $projection.ConnectionId = _Connection.ConnectionID

{
  key travel_id           as TravelId,
  key booking_id          as BookingId,

      booking_date        as BookingDate,
      customer_id         as CustomerId,
      carrier_id          as CarrierId,
      connection_id       as ConnectionId,
      
      flight_date         as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price        as FlightPrice,
      @Semantics.currencyCode: true
      currency_code       as CurrencyCode,
      booking_status      as BookingStatus,
      last_change_at      as LastChangeAt,

      _Travel,
      _BookingSupplement,
      _Customer,
      _Carrier,
      _Connection
}
