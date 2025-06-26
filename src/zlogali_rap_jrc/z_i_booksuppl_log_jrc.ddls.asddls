//@AbapCatalog.viewEnhancementCategory: [ #NONE ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@EndUserText.label: 'Interface - Booking Supplement'

@Metadata.ignorePropagatedAnnotations: true

//@ObjectModel.usageType: { serviceQuality: #X,
//                          sizeCategory:   #S,
//                          dataClass:      #MIXED }

define view entity Z_I_BOOKSUPPL_LOG_JRC
  as select from zbooksupp_logjrc as BookingSupplement

  association to parent Z_I_BOOKING_LOG_JRC   as _Booking
    on  $projection.travel_id  = _Booking.travel_id
    and $projection.booking_id = _Booking.booking_id

  association [1..1] to Z_I_TRAVEL_LOG_JRC    as _Travel
    on $projection.travel_id = _Travel.travel_id

  association [1..1] to /DMO/I_Supplement     as _Product
    on $projection.supplement_id = _Product.SupplementID

  association [1..*] to /DMO/I_SupplementText as _SupplementText
    on $projection.supplement_id = _SupplementText.SupplementID

{
  key travel_id,
  key booking_id,
  key booking_supplement_id,

      supplement_id,

      @Semantics.amount.currencyCode: 'currency_code'
      price,

      currency_code,

      @Semantics.systemDateTime.lastChangedAt: true
      _Travel.last_changed_at,

      _Booking,
      _Travel,
      _Product,
      _SupplementText
}
