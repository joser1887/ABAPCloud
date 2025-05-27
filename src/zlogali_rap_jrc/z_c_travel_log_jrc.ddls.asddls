@AccessControl.authorizationCheck: #CHECK

@EndUserText.label: 'Consumption - Travel'

@Metadata.allowExtensions: true

define root view entity Z_C_TRAVEL_LOG_jrc
  as projection on Z_I_TRAVEL_LOG_JRC

{
  key TravelId,

      @ObjectModel.text.element: [ 'AgencyName' ]
      AgencyId           as AgencyId,

      _Agency.Name       as AgencyName,

      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId         as CustomerId,

      _Customer.LastName as CustomerName,
      BeginDate          as BeginDate,
      EndDate            as EndDate,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee         as BookingFee,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice         as TotalPrice,

      @Semantics.currencyCode: true
      CurrencyCode       as CurrencyCode,

      Description        as Description,
      OverallStatus      as TravelStatus,
      LastChangedAt      as LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child Z_c_BOOKING_LOG_JRC,

      _Currency,
      _Customer
}
