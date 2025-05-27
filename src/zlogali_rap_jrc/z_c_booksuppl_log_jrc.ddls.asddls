@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Consumption - Booking Supplement'

@Metadata.allowExtensions: true

define view entity Z_C_BOOKSUPPL_LOG_JRC
  as projection on Z_I_BOOKSUPPL_LOG_JRC

{
  key TravelId                    as TravelId,
  key BookingId                   as BookingId,
  key BookingSupplementId         as BookingSupplementId,

      SupplementId                as SupplementId,
      _SupplementText.Description as SupplementDescription : localized,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price                       as Price,

      @Semantics.currencyCode: true
      Currency                    as CurrencyCode,

      LastChangedAt               as LastChangedAt,

      /* Associations */
      _Travel  : redirected to Z_C_TRAVEL_LOG_jrc,
      _Booking : redirected to parent Z_c_BOOKING_LOG_JRC,

      _Product,
      _SupplementText
}
