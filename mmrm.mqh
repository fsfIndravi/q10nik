
// MONEY MANAGEMENT && RISK MANAGEMENT
// Initializing global variables

double deposit_convert_koef;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void convert_currency (){
   string acc_currency = AccountCurrency ();
   if (acc_currency != base_currency){
      if (acc_currency == "BIT") deposit_convert_koef = MarketInfo ("BTCUSD",MODE_BID) / 1000000;
      if (acc_currency == "BTC") deposit_convert_koef = MarketInfo ("BTCUSD",MODE_BID);
      if (acc_currency == "EUR") deposit_convert_koef = MarketInfo ("EURUSD",MODE_BID);
      if (acc_currency == "JPY") deposit_convert_koef = 1 / MarketInfo ("USDJPY",MODE_BID);
      if (acc_currency == "RUB") deposit_convert_koef = 1 / MarketInfo ("USDRUB",MODE_BID);
      }
   }
