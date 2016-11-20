//+------------------------------------------------------------------+
//|                                                    Q10NIK DRIVER |
//|                                                   Zhinzhich Labs |
//|                                                                  |
//+------------------------------------------------------------------+

//#include "Waves.mqh"
#include "Orders.mqh"
#include "Candles.mqh"
#include "Timeframes.mqh"
#include "Stats.mqh"
#include "Trendlines.mqh"
#include "arraysZIGZAG.mqh"

WavesClass        wave;
OrdersClass       order;
CandlesClass      candle;
TimeframesClass   timeframe;
StatsClass        stats;

TrendlinesClass   trendlines_OP_SELL;
TrendlinesClass   trendlines_OP_BUY;

// Current version variables

string version="DRIVER 1.01";
string comment_ver="standard edition";

// Customizable parameters

extern string  comment1 = "==== Overall options =====";
extern double  deal_costs_max_koef = 0.06;                        // Maximum percent of transaction costs (spread+commission) from estimated profit per deal
extern int     deal_duration_max_minutes = 1440;                  // Maximum period (in minutes) of Impulse wave for a deal (transaction)
extern double  deal_risk_percent = 3.0;                           // Risk percent per deal (percent from deposit)
extern double  deal_RR_min = 3.0;                                 // Deal RR min
extern bool    limit_orders = false;                              

extern string  comment2 = "==== Drivers options =====";
extern double  driver_range_avg_koef = 2.0;
extern double  driver_strength_koef = 0.87;
extern double  driver_retrace_koef = 0.6;
extern double  touch_distance_koef = 0.15;                        // Driver length koef for touch distance

extern string  comment4 = "==== Tech options =====";
extern int     timeframe_Lowest = 1;
extern int     seekShiftMax = 200;
extern int     spread_default = 20;
extern double  commission_default_per_lot = 10;                   // Amount in deposit currency Per 100,000 of base currency
extern double  spread_max_avg_koef = 2.0;
extern int     average_period = 15;
extern bool    showHistory = true;
extern bool    showStats = false;
extern int     skiphours = 0;




// Signals variables

bool     signal_BUY;
bool     signal_SELL;
bool     signal_BUY_MAIN;
bool     signal_SELL_MAIN;
bool     signal_BUY_ADD;
bool     signal_SELL_ADD;

// Tech variables

int      tick_count;
string   line_time;
double   lotStep;
double   lotMin;
double   lotMax;
int      lotDigits;
double   tickValue;
double   stopoutLevel;
int      spread;
int      spread_max;
int      spread_avg;
int      spreadArray[10];
double   commission;
double   costs;
int      costs_pips;
int      BUY = 1;
int      SELL = -1;
int      tf [10];
int      timeframe_Main;
int      found_wave_BUY;
int      found_wave_SELL;


// Global variables

int      time_start;
bool     showLog = false;
string   logLineString [300];
color    logLineColor [300];
int      logLineCount = 0;
int      lastTime;








//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+

int init()
  {
   
   // Logger
   stats.logger.Init ("Q10NIK "+version);
   string comment_global=StringConcatenate("Q10NIK ver. ",version,"   ",comment_ver);
   Comment(comment_global);
   line_time=StringConcatenate("|M",Period(),"| ",TimeYear(TimeCurrent()),".",TimeMonth(TimeCurrent()),".",TimeDay(TimeCurrent()),"  ",TimeHour(TimeCurrent()),":",TimeMinute(TimeCurrent()),":",TimeSeconds(TimeCurrent()),"  ");
   
   // Arrays and variables
   time_start = TimeCurrent ();
   tick_count = 0;
   
   // Tech variables init
   tickValue = MarketInfo (Symbol(),MODE_TICKVALUE);
   lotMin = MarketInfo (Symbol (),MODE_MINLOT);
   lotMax = MarketInfo (Symbol (),MODE_MAXLOT);
   lotStep = MarketInfo (Symbol (),MODE_LOTSTEP);
   if (lotStep < 0.01) lotDigits = 2;
   if (lotStep == 0.01) lotDigits = 2;
   if (lotStep == 0.1) lotDigits = 1;
   if (lotStep >= 1) lotDigits = 0;
   tf [1] = 1;
   tf [2] = 5;
   tf [3] = 15;
   tf [4] = 30;
   tf [5] = 60;
   tf [6] = 240;
   tf [7] = 1440;
   tf [8] = 10080;
   tf [9] = 43200;
   
   // initializing waves
   wave.Init (timeframe_Lowest, seekShiftMax, deal_costs_max_koef, deal_duration_max_minutes, 0);
   
   return(0);
   
   

  }





//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+

int deinit()
  {
   // Logger
   stats.logger.Deinit ();
   return(0);
  }
  
  
  
  
  
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

int start()
  {

   showLog = false;
   
   logLineCount = 0;
   
   spread = MarketInfo (Symbol (),MODE_SPREAD);
   
   if (GlobalVariableGet ("gv_show_log") == 1) showLog = true;
   
   costs_set ();
   
//   _positions_close ();

   if (TimeCurrent () - time_start < skiphours * 3600) return (0);
   
   _positions_open ();
   
   log_show ();
   
   tick_count++;
      
   return (0);
   
  }
  



//+---------------------------------------------------------------------------------------------------------+
//  FID?09: function returns date and time in string format
//+---------------------------------------------------------------------------------------------------------+

string get_date_string(int time_input){
   string string_result=StringConcatenate(TimeYear(time_input),".",TimeMonth(time_input),".",TimeDay(time_input),"   ",TimeHour(time_input),":",TimeMinute(time_input));
   if (time_input == 0) string_result = "0";
   return (string_result);
   }


  
  
//+---------------------------------------------------------------------------------------------------------+
//  FID?45: функция укороченная для логирования данных
//+---------------------------------------------------------------------------------------------------------+

void log_message(string message_local,int color_local){
   string line_local = message_local;
   StringToCharArray (line_local,p);
   log(p,color_local);
  }
  
  
  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void close_all_orders (){
   bool closeResult = false;
   for (int t = OrdersTotal (); t >=0; t--){
      if (OrderSelect (t,SELECT_BY_POS,MODE_TRADES)){
         if (OrderMagicNumber () > 0){
            if (OrderType () == OP_BUY) closeResult = OrderClose (OrderTicket(),OrderLots(),Bid,5,Blue);
            if (OrderType () == OP_SELL) closeResult = OrderClose (OrderTicket(),OrderLots(),Ask,5,Blue);
            }
         }
      }   
   }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void _positions_close (){
   
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void _positions_open ()
   
    {
   
    double   lotToOpen;
    double   sl, tp;
    int      ticket;
    double   sl_price;

    // Init array zigzag
    if (iBarShift(Symbol(),5,last_zigzag_time) >= 1 || last_zigzag_time == 0){
        last_zigzag_time = TimeCurrent ();
        arrays (1,5);
        arrays (1,4);
    }

    arrays(1,1);
    arrays(1,2);
    arrays(1,3);
   
    // 1. BUY ORDERS
    // 1.1. FIND WAVE BUY
    if (iBarShift (Symbol(), 5, lastTime, false) > 0 || lastTime == 0){
        lastTime = TimeCurrent ();
        found_wave_BUY = wave.FindAll (OP_BUY,100);
        // if (deal_costs_max_koef>0) found_wave_BUY = wave.FindCascade(OP_BUY,100, 1440, 1);  
        //found_wave_BUY = wave.FindCascade (OP_BUY, 0.00300, 1440,1);
        log_add_line ("OP_BUY="+OP_BUY+"   OP_SELL="+OP_SELL,Red);
        //if (deal_costs_max_koef<=0){Alert("Cannot open orders: deal_costs_max_koef <=0");}
        log_add_line ("found_wave_BUY="+found_wave_BUY+"   Minimum length="+Point * costs_pips / deal_costs_max_koef,Red);
        log_add_line ("impulse.time_Start="+get_date_string(wave.cascade.impulse[1].timeStart),Red);
        //trendline.DrawLine ("nameLine",Red,1,wave.impulse.timeStart,wave.impulse.price_Start,wave.impulse.timeEnd,wave.impulse.price_End);
        showLog = true;
    }
    // 1.2. CHECK SIGNAL BUY
    if (found_wave_BUY > 0
    && !signal_BUY_MAIN
    && order.dealBuy.countOrders_Buy == 0){
        //     Print ("wave.impulse.timeEnd="+get_date_string(wave.impulse.timeEnd));
        int trendlines_count = trendlines_OP_SELL.FindInPeriod (OP_SELL, wave.impulse.timeEnd, TimeCurrent());
        //      Print ("Trendlines count = "+trendlines_count);
        ObjectCreate ("trendline_SELL", OBJ_TREND, 0, 0,trendlines_OP_SELL.trendline[1].wave[1].time_start, trendlines_OP_SELL.trendline[1].wave[1].price_start, trendlines_OP_SELL.trendline[1].wave[3].time_start, trendlines_OP_SELL.trendline[1].wave[3].price_start);
        ObjectSet("trendline_SELL", OBJPROP_STYLE, STYLE_DASH);
        ObjectSet("trendline_SELL", OBJPROP_WIDTH, 1);
        ObjectSet("trendline_SELL", OBJPROP_RAY, true);
        ObjectSet("trendline_SELL", OBJPROP_COLOR, Red);
    } 
   
   
   //if (found_wave_BUY > 0
   //   && !signal_BUY_MAIN
   //   && order.dealBuy.countOrders_Buy == 0
   //   && Bid <= wave.impulse.price_End - 0.33 * MathAbs (wave.impulse.length)
   //   && MathAbs (wave.impulse.length) >= 0.66 * MathAbs (wave.opposite.length)
   //   && check_spread ()){
   //      signal_BUY_MAIN = true;
   //      }
   // 1.3. CHECK ENTER BUY
   if (signal_BUY_MAIN){
      log_add_line ("wave.impulse.priceEnd="+wave.impulse.price_End+"   wave.impulse.length="+wave.impulse.length+"   wave.impulse.timeEnd="+get_date_string(wave.impulse.timeEnd)+"    impulse.duration="+wave.impulse.duration/60,Blue);
      lotToOpen = NormalizeDouble (AccountBalance () / (1000 / 0.5),lotDigits);
      if (lotToOpen < lotMin && lotToOpen > 0) lotToOpen = lotMin;
      if (lotToOpen > lotMax && lotToOpen > 0) lotToOpen = lotMax;
      sl = wave.impulse.price_Start - 10 * Point;
      tp = iLow (Symbol(), 5, iLowest (Symbol (), 5, MODE_LOW, iBarShift (Symbol(), 5, wave.impulse.timeEnd,false)));
      ticket = OrderSend (Symbol(),OP_BUY,lotToOpen,Ask,5,0,0,1,1,0,Blue);
      if (ticket > 0){
         signal_BUY_MAIN = false;
         if (OrderSelect (ticket,SELECT_BY_TICKET,MODE_TRADES)){
            log_add_line ("STARTING SERIE BUY ORDER #"+ticket+" at price "+DoubleToStr (Ask,Digits)+ ". Lot "+lotToOpen,DarkGreen); 
            order.Add (ticket, OP_BUY, wave.impulse.timeStart, wave.impulse.timeEnd, TimeCurrent ());
            order.RefreshFULL ();
            }
         showLog = true;
         }
      else log_add_line ("ERROR SENDING ORDER BUY at price "+DoubleToStr (Ask,Digits)+". Lot "+lotToOpen+".   Reason: "+ErrorDescription (GetLastError()),Red);
      log_add_line ("wave.RetraceRatioMax="+wave.RetraceRatioMax (OP_BUY, wave.impulse.timeStart, wave.impulse.timeEnd, wave.impulse.price_Start, wave.impulse.price_End)+"   order.dealBuy.time_LastHigh="+get_date_string(order.dealBuy.time_LastHigh),Blue);
      showLog = true;
      }
         

   // 1.3. ENTER ADD ORDER BUY
   
   //log_add_line ("order.dealBuy.lot_Buy="+order.dealBuy.lot_Buy+"    wave.FindAll (OP_BUY, 0.0030)="+wave.FindAll (OP_BUY, 0.0030)+"   order.totals.countBuy="+order.totals.countBuy,Red);
   //log_add_line ("found_wave_BUY="+found_wave_BUY+"   order.dealBuy.countOrders_Buy="+order.dealBuy.countOrders_Buy+"   wave.impulse.priceEnd="+wave.impulse.price_End,Red); 
   
   if (!signal_BUY_ADD
      && found_wave_BUY > 0
      && order.dealBuy.countOrders_Buy > 0
      && Bid <= wave.impulse.price_End - 0.33 * MathAbs (wave.impulse.length)
      && wave.impulse.timeEnd > order.dealBuy.time_LastHigh
      && MathAbs (wave.impulse.length) >= 0.66 * MathAbs (wave.opposite.length)
      && !check_spread ()){
         signal_BUY_ADD = true;
         }
   if (signal_BUY_ADD)
         {
         lotToOpen = NormalizeDouble (AccountBalance () / (1000 / 0.5),lotDigits);
         if (lotToOpen < lotMin && lotToOpen > 0) lotToOpen = lotMin;
         if (lotToOpen > lotMax && lotToOpen > 0) lotToOpen = lotMax;
         sl = wave.impulse.price_Start - 10 * Point;
         tp = iLow (Symbol(), 5, iLowest (Symbol (), 5, MODE_LOW, iBarShift (Symbol(), 5, wave.impulse.timeEnd,false)));
         ticket = OrderSend (Symbol(),OP_BUY,lotToOpen,Ask,5,0,0,1,1,0,Blue);
         if (ticket > 0)
            {
            signal_BUY_ADD = false;
            if (OrderSelect (ticket,SELECT_BY_TICKET,MODE_TRADES))
               {               
               log_add_line ("ADDING BUY ORDER #"+ticket+" at price "+DoubleToStr (Ask,Digits)+ ". Lot "+lotToOpen,DarkGreen);
               order.Add (ticket, OP_BUY, wave.impulse.timeStart, wave.impulse.timeEnd, TimeCurrent ());
               order.RefreshFULL ();
               }
            showLog = true;
            }
         else log_add_line ("ERROR SENDING ORDER BUY at price "+DoubleToStr (Ask,Digits)+". Lot "+lotToOpen+".   Reason: "+ErrorDescription (GetLastError()),Red);
         showLog = true;
         }  
   }



//+------------------------------------------------------------------+
//| function returns error description
//+------------------------------------------------------------------+
   
string ErrorDescription(int error_code){
   string result;
   switch(error_code){
      case 1:
         result ="No error returned, but the result is unknown.";
         break;
      case 2:
         result ="Common error.";
         break;
      case 3:
         result ="Invalid trade parameters.";
         break;
      case 4:
         result ="Trade server is busy.";
         break;
      case 5:
         result ="Old version of the client terminal.";
         break;
      case 6:
         result ="No connection with trade server.";
         break;   
      case 7:
         result ="Not enough rights.";
         break;   
      case 8:
         result ="Too frequent requests.";
         break;         
      case 9:
         result ="Malfunctional trade operation.";
         break;          
      case 64:
         result ="Account disabled.";
         break; 
      case 65:
         result ="Invalid account.";
         break; 
      case 128:
         result ="Trade timeout.";
         break; 
      case 129:
         result ="Invalid price.";
         break;          
      case 130:
         result ="Invalid stops.";
         break; 
      case 131:
         result ="Invalid trade volume.";
         break; 
      case 132:
         result ="Market is closed.";
         break; 
      case 133:
         result ="Trade is disabled.";
         break; 
      case 135:
         result ="Price changed.";
         break; 
      case 136:
         result ="Off quotes.";
         break; 
      case 137:
         result ="Broker is busy.";
         break; 
      case 138:
         result ="Requote.";
         break; 
      case 139:
         result ="Order is locked.";
         break; 
      case 140:
         result ="Long positions only allowed.";
         break; 
      case 141:
         result ="Too many requests.";
         break; 
      case 145:
         result ="Modification denied because order too close to market.";
         break; 
      case 146:
         result ="Trade context is busy.";
         break; 
      case 147:
         result ="Expirations are denied by broker.";
         break; 
      case 148:
         result ="The amount of open and pending orders has reached the limit set by the broker.";
         break; 
      case 149:
         result ="An attempt to open a position opposite to the existing one when hedging is disabled.";
         break; 
      case 150:
         result ="An attempt to close a position contravening the FIFO rule.";
         break; 
      default: 
         result = "No error";
      }
   return(result);
   }








//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void clear_objects (){   
   for(int tLocal=ObjectsTotal(); tLocal>=0; tLocal--){
     if(StringSubstr(ObjectName(tLocal),0,9)=="clearable") ObjectDelete(ObjectName(tLocal));
     }
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void log_show (){
   if (showLog){
      // Показываем полностью все возможные логи
      log_message ("===============   SHOW LOG ON EVENT. TICK #"+tick_count+". TIME "+get_date_string (TimeCurrent())+"  ===============",Brown);
     // Show ADD lines
     for (int indexLocal = 0; indexLocal < logLineCount; indexLocal ++) log_message (logLineString [indexLocal],logLineColor [indexLocal]);
     GlobalVariableSet ("gv_show_log",0);
   } // if showLog
}
 
 
 
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void log_add_line (string stringLogLocal, color colorLocal){   
   logLineString [logLineCount] = stringLogLocal;
   logLineColor [logLineCount] = colorLocal;
   logLineCount++;
}
   



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void delete_label (int orderTicketLocal){
   string nameLocal = StringConcatenate ("OrderLabel_",orderTicketLocal);
   ObjectDelete (nameLocal);
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool check_spread (){
   if (spread_avg > 0){
      if (spread > spread_max_avg_koef * spread_avg){
         Alert ("Spread exceeds limit of "+spread_max_avg_koef * spread_avg+". No new orders");
         return (false);
      }
   }
   return (true);
}
  





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int deal_new_id (){
   string id_string = StringSubstr (TimeCurrent (),StringLen(TimeCurrent()) - 6,6);
   log_add_line ("deal_id_new = "+id_string,Red);
   return (StrToInteger (id_string));
}




 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void costs_set ()
   {
   
   // Calculating average spread;   
   int spread_total = 0;   
   for (int s = 9; s > 0; s--){
      spreadArray [s] = spreadArray [s-1];
      spread_total += spreadArray [s];
      }      
   spreadArray [0] = MarketInfo (Symbol(), MODE_SPREAD);
   spread_total += spreadArray [0];
   spread_avg = NormalizeDouble (spread_total / 10,0);     
   if (spreadArray [9] == 0){
      spread_avg = spread_default;
      }
      
   // Calculating commission   
   if (OrdersHistoryTotal () == 0) 
      commission = commission_default_per_lot;
   else {
      for (int order = 0; order <= OrdersHistoryTotal ()-1; order++){
         if (OrderSelect (order,SELECT_BY_POS,MODE_HISTORY)){
            if (OrderSymbol () == Symbol () && OrderLots () > 0){
               commission = OrderCommission () / OrderLots ();
               }               
            }
         }
       }
      
   // Calculating costs per lot   
   costs = commission + spread_avg * tickValue;   
   if (tickValue > 0) 
      costs_pips = NormalizeDouble (costs / tickValue,0);
   
   }
   
