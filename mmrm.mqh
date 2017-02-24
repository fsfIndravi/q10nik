
// MONEY MANAGEMENT && RISK MANAGEMENT
// Initializing global variables

double balance_convert (double balance, string acc_currency, string dest_currency){
   if (acc_currency==dest_currency) return (balance);
   // Converting deposit amount
   double balance_dest;
   if (acc_currency == "BIT") balance_dest = MarketInfo ("BTCUSD",MODE_BID) / 1000000;
   if (acc_currency == "BTC") balance_dest = MarketInfo ("BTCUSD",MODE_BID);
   if (acc_currency == "EUR") balance_dest = MarketInfo ("EURUSD",MODE_BID);
   if (acc_currency == "JPY") balance_dest = 1 / MarketInfo ("USDJPY",MODE_BID);
   if (acc_currency == "RUB") balance_dest = 1 / MarketInfo ("USDRUB",MODE_BID);
   
   return (balance_dest);
   
   }
