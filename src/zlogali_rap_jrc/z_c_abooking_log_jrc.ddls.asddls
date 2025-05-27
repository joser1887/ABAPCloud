@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Consumption - Booking Approval'

@Metadata.allowExtensions: true

define view entity Z_C_ABOOKING_LOG_JRC
  as projection on Z_I_BOOKING_LOG_JRC

{
  key TravelId      as TravelId,
  key BookingId     as BookingId,

      BookingDate   as BookingDate,
      CustomerId    as CustomerId,

      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId     as CarrierId,

      _Carrier.Name as CarrierName,
      ConnectionId  as ConnectionId,
      FlightDate    as FlightDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice   as FlightPrice,

      @Semantics.currencyCode: true
      CurrencyCode  as CurrencyCode,

      BookingStatus as BookingStatus,
      LastChangeAt  as LastChangeAt,

      /* Associations */
      _Travel : redirected to parent Z_C_ATRAVEL_LOG_JRC,

      _Customer,
      _Carrier
}
