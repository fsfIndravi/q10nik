//+------------------------------------------------------------------+
//|                                                   Q10NIK GREEDER |
//|                                                   Zhinzhich Labs |
//+------------------------------------------------------------------+

//#include "Waves.mqh"
#include "Orders.mqh"
#include "Candles.mqh"
#include "Timeframes.mqh"
#include "Stats.mqh"
#include "Trendlines.mqh"
#include "arraysZIGZAG.mqh"

//WavesClass        wave;
OrdersClass       order;
CandlesClass      candle;
TimeframesClass   timeframe;
StatsClass        stats;

//TrendlinesClass   trendlines_OP_SELL;
//TrendlinesClass   trendlines_OP_BUY;

// Current version variables

string version="DRIVER 1.01";
string comment_ver="standard edition";

// Customizable parameters

extern string  comment1 = "==== Overall options =====";
extern double  deal_costs_max_koef = 0.06;                        // Maximum percent of transaction costs (spread+commission) from estimated profit per deal
extern int     deal_duration_max_minutes = 1440;                  // Maximum period (in minutes) of Impulse wave for a deal (transaction)
extern double  deal_risk_percent = 3.0;                           // Risk percent per deal (percent from deposit)
extern double  deal_RR_min = 1;                                   // Deal RR min
extern bool    limit_orders = false;                              
extern double  grid_lot_inc_koef = 2.0;
extern double  grid_risk_start_percent = 3.0;
extern int     grid_steps_max = 5;

extern string  comment2 = "==== Drivers options =====";
extern double  driver_range_avg_koef = 2.0;
extern double  driver_strength_koef = 0.87;
extern double  driver_retrace_koef = 0.6;
extern double  touch_distance_koef = 0.15;                        // Driver length koef for touch distance

extern string  comment4 = "==== Tech options =====";
extern int     timeframe_Lowest = 1;
extern int     timeframe_koef = 4;
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
double   stopoutLevel;
int      BUY = 1;
int      SELL = -1;
int      tf [10];
int      timeframe_Main;
int      found_wave_BUY;
int      found_wave_SELL;

// Grid variables

double   grid_BUY_price [10], grid_SELL_price [10];
int      grid_BUY_lastClosedNumber, grid_SELL_lastClosedNumber;
double   grid_BUY_lastClosed_Profit, grid_SELL_lastClosed_Profit;
double   grid_BUY_lotStart, grid_SELL_lotStart;
bool     grid_BUY_active, grid_SELL_active;



// Global variables

int      time_start;
bool     showLog = false;
string   logLineString [300];
color    logLineColor [300];
int      logLineCount = 0;
int      lastTime;
bool     arrays_done [7];








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
   
   // Zigzag parameters
   
   depth [6] = 192;
   depth [5] = 96;
   depth [4] = 48;
   depth [3] = 24;
   depth [2] = 12;
   depth [1] = 6;   
   
   swings_max [1] = 7;
   swings_max [2] = 18;
   swings_max [3] = 12;
   swings_max [4] = 12;
   swings_max [5] = 12;
   
   // Deals parameters
   
   if (deal_costs_max_koef == 0) deal_costs_max_koef = 0.05;
   
   // initializing waves
   //wave.Init (timeframe_Lowest, seekShiftMax, deal_costs_max_koef, deal_duration_max_minutes, 0);
   
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

   if (TimeCurrent () - time_start < skiphours * 3600) return (0);

   showLog = false;

   arrays_done [1] = false;
   arrays_done [5] = false;
   
   logLineCount = 0;
   
   spread = MarketInfo (Symbol (),MODE_SPREAD);
   
   if (GlobalVariableGet ("gv_show_log") == 1) showLog = true;
   
   costs_set (spread_default, commission_default_per_lot);
   
   //if (OrdersTotal () > 0) return (0);
   
   _positions_close ();
   
   _positions_open ();
   
   log_show ();

   //draw_f_numbers ();
   
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

   double lotToClose;
   bool closeResult;

   order.RefreshFast ();
   
   for (int orders = order.totals.count; orders > 0; orders--){

      // Optimizing performance for arrays func call
      if (!arrays_done [1]){arrays(1,1);arrays_done[1]=true;}
      if (!arrays_done [5]){arrays(1,5);arrays_done[5]=true;}
           
      // 1. 3-wave F5 with 50+% retrace 
      
      if (order.positions[orders].direction == OP_BUY
      // no popunty outsideswing 
      && outsideswing_check (5, OP_BUY) == 0
      && f_length [5][0] > 0
      && MathAbs (f_length [5][2]) > MathAbs (f_length [5][4])
      && MathAbs (f_length [5][0]) > MathAbs (f_length [5][1])
      && MathAbs (f_length [5][2]) > MathAbs (f_length [5][1])
      && MathAbs (f_length [5][1]) > 0.5 * MathAbs (f_length [5][2])
      // f1 pattern
      && ((f_length [1][0] > 0
            && MathAbs (f_length [1][0]) < MathAbs (f_length [1][2])
            && MathAbs (f_length [1][1]) < MathAbs (f_length [1][2])
            && MathAbs (f_length [1][2]) > MathAbs (f_length [1][4]))
        || 
        (f_length [1][0] < 0
            && f_price [1][1] >= f_price [5][0] // f1 wave must start from the highest high
            && MathAbs (f_length [1][0]) < 1.15 * MathAbs (f_length [1][1])
            && MathAbs (f_length [1][0]) >= 0.5 * MathAbs (f_length [1][1])
            && MathAbs (f_length [1][1]) < MathAbs (f_length [1][3])))
      && iLow (Symbol(),1,0) < iLow (Symbol(),1,1)
      && Bid < iLow (Symbol(),1,1)
      && f_time [5][2] > order.positions[orders].openTime
      ){
          
        lotToClose = NormalizeDouble (order.positions[orders].lot,lotDigits);
        closeResult = OrderClose (order.positions[orders].ticket,lotToClose,Bid,5,Yellow);
        if (closeResult) 
           {
           //lastCloseTime_Buy = TimeCurrent ();
           log_add_line ("Close order BUY #"+order.positions[orders].ticket+" F5: 3-wave F5 ",Red);
           showLog = true;
           }
      }

      // 2. Opposite OU F5
      log_add_line ("order.positions[orders].direction == "+order.positions[orders].direction,Red); 
      log_add_line ("order.positions[orders].openPrice == "+order.positions[orders].openPrice,Red); 

      if (order.positions[orders].direction == OP_BUY
      // no popunty outsideswing 
      && outsideswing_check (5, OP_BUY) == 0
      // f5 pattern
      && ((f_length [5][0] > 0
            && MathAbs (f_length [5][1]) > MathAbs (f_length [5][2])
            && MathAbs (f_length [5][2]) > MathAbs (f_length [5][3])
            && MathAbs (f_length [5][0]) >= 0.5 *  MathAbs (f_length [5][1]))
        ||
        (f_length [5][0] < 0
            && MathAbs (f_length [5][0]) > MathAbs (f_length [5][1])
            && MathAbs (f_length [5][1]) > MathAbs (f_length [5][2])
            && iHigh (Symbol (), 1, iHighest (Symbol (),1,f_shift [5][0],0)) >= f_price [5][0] + 0.5 * MathAbs (f_length [5][0]) * Point))
      // f1 pattern
      && ((f_length [1][0] > 0
            && MathAbs (f_length [1][0]) < MathAbs (f_length [1][2])
            && MathAbs (f_length [1][1]) < MathAbs (f_length [1][2])
            && MathAbs (f_length [1][2]) > MathAbs (f_length [1][4]))
        || 
        (f_length [1][0] < 0
            && f_price [1][1] >= f_price [5][0] // f1 wave must start from the highest high
            && MathAbs (f_length [1][0]) < 1.15 * MathAbs (f_length [1][1])
            && MathAbs (f_length [1][0]) >= 0.5 * MathAbs (f_length [1][1])
            && MathAbs (f_length [1][1]) < MathAbs (f_length [1][3])))
      && iLow (Symbol(),1,0) < iLow (Symbol(),1,1)
      && Bid < iLow (Symbol(),1,1)
      && f_time [5][2] > order.positions[orders].openTime
      ){
          
        lotToClose = NormalizeDouble (order.positions[orders].lot,lotDigits);
        closeResult = OrderClose (order.positions[orders].ticket,lotToClose,Bid,5,Yellow);
        if (closeResult) 
           {
           //lastCloseTime_Buy = TimeCurrent ();
           log_add_line ("Close order BUY #"+order.positions[orders].ticket+": opposite OU F5 ",Red);
           showLog = true;
           }
      }

      
         
   }
}
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void delete_limits (int orderType){

   if (orderType == OP_BUYLIMIT){
      for (int a_pos = 0; a_pos <= OrdersTotal ()-1; a_pos++){
         if (OrderSelect (a_pos, SELECT_BY_POS, MODE_TRADES)){
            if (OrderSymbol () == Symbol () 
            && OrderType () == OP_BUYLIMIT
            && OrderMagicNumber () > 0){
            OrderDelete (OrderTicket (), clrNONE);
            }
         }
      }
  }
      
  if (orderType == OP_SELLLIMIT){
      for (a_pos = 0; a_pos <= OrdersTotal ()-1; a_pos++){
         if (OrderSelect (a_pos, SELECT_BY_POS, MODE_TRADES)){
            if (OrderSymbol () == Symbol () 
            && OrderType () == OP_SELLLIMIT
            && OrderMagicNumber () > 0){
            OrderDelete (OrderTicket (), 0);
            }
         }
      }
   }
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
    double   correctorPrice;
    bool     patternCur            = false;

    // ENTER BUY ORDERS 
    if (iHigh (Symbol(),1,0) > iHigh (Symbol(),1,1)
    && Bid > iHigh (Symbol(),1,1)
    && check_spread ())
        patternCur = true;
   
    if (patternCur){
        // Check refresh zigzag arrays
        if (!arrays_done [5]){arrays(1,5);arrays_done[5]=true;}
        int f = 5;
        int zone = 0;
        int index_OS = outsideswing_check (f, OP_SELL);

        //double FindCorrector (int timeframeLocal, int directionLocal, int vertex_time);

        //if (f_length [f][0] < 0
        //&& MathAbs (f_length [f][1]) > 0.66 * MathAbs (f_length [f][2])
        //&& MathAbs (f_length [f][2]) > MathAbs (f_length [f][4])
        //&& f_price [f][0] <= f_price [f][2] + 0.33 * MathAbs (f_length [f][1]) * Point
        ////   int TimeframesClass::Highest (int timeStart, int timeEnd, int fullCandlesCountMin){
        //// double FindMax (int x_timeframe, int x_direction, int x_timeEarlier, int x_timeLater, bool x_unnullifyed);
        //&& candle.FindCorrector (
        //&& MathAbs (candle.FindMax (timeframe.Highest (f_time [f][3],f_time [f][2],1),OP_SELL,f_time [f][3],f_time [f][2],false)) > MathAbs (candle.FindMax (timeframe.Highest (f_time [f][3],f_time [f][2],1),OP_SELL,f_time [f][3],f_time [f][2],false))){ // Candles get slower
        //    zone = 1;
        //}
        
        // 1. MAIN ORDER BUY
        // 1.1. Enter on 5+wave completion (zone 1)
        if (f_length [f][0] < 0
        && (index_OS == 0 || index_OS > 3)
        && MathAbs (f_length [f][0]) > MathAbs (f_length [f][1])
        && MathAbs (f_length [f][0]) < MathAbs (f_length [f][2]) // wave [0] is less than 2 - the last wave is 5th
        && MathAbs (f_length [f][1]) < MathAbs (f_length [f][2])
        && MathAbs (f_length [f][3]) < MathAbs (f_length [f][4])
        && MathAbs (f_length [f][1]) > 0.38 * MathAbs (f_length [f][2]))
            zone = 1;
        
        // 1.2. Enter on 3 wave completion (zone 2)
        if (f_length [f][0] < 0
        && (index_OS == 0 || index_OS > 3)
        && MathAbs (f_length [f][0]) > MathAbs (f_length [f][1])
        && MathAbs (f_length [f][0]) < MathAbs (f_length [f][2]) // wave [0] is less than 2 - the last wave is 5th
        && MathAbs (f_length [f][1]) < MathAbs (f_length [f][2])
        && MathAbs (f_length [f][2]) > MathAbs (f_length [f][4]) // wave [2] must be accelerating
        && MathAbs (f_length [f][1]) > 0.5 * MathAbs (f_length [f][2]))
            zone = 2;

       // 1.3. Completed outsideswing

       int index_OS_comp = outsideswing_completed (f,OP_SELL);
       double price_max = vertex_max (f,index_OS_comp,1);

       if (f_length [f][0] < 0
       && index_OS_comp >= 4
       && f_price [f][0] < f_price [f][index_OS_comp]
       && price_max >= 0.5 * (f_price [f][index_OS_comp] + f_price [f][index_OS_comp+1])
       && MathAbs (f_length [f][0]) > MathAbs (f_length [f][1]))
           zone = 3;
        
        if (zone > 0){
            // Finding lower impulse
            // Optimizing performance for arrays func call
            if (!arrays_done [1]){arrays(1,1);arrays_done[1]=true;}
            arrays (1,1);
            int pattern = 0;

            // Pattern 1: 50% from the opposite deccelerating wave
            if (f_length [1][0] > 0
            && MathAbs (f_length [1][1]) < MathAbs (f_length [1][3]) // Decelerating previous opposite wave
            && f_price [1][1] <= f_price [f][0]                      // Favor wave starts from the end of the wave [f][0]
            && Ask <= f_price [f][0] + 0.33 * MathAbs (f_length [f][0]) * Point
            && MathAbs (f_length [1][0]) >= 0.5 * MathAbs (f_length [1][1])
            && MathAbs (f_length [1][0]) < 1.165 * MathAbs (f_length [1][1]))
                pattern = 1;

            // Pattern 2: lower low from the opposite accelerating wave with 50+% retrace
            if (f_length [1][0] < 0
            && MathAbs (f_length [1][1]) > MathAbs (f_length [1][3])
            && MathAbs (f_length [1][2]) > MathAbs (f_length [1][4])
            && MathAbs (f_length [1][0]) > MathAbs (f_length [1][1])
            && MathAbs (f_length [1][0]) < MathAbs (f_length [1][2])
            && MathAbs (f_length [1][1]) >= 0.5 * MathAbs (f_length [1][2]))
                pattern = 2;

            // Pattern 3: lower low from the opposite accelerating 3-wave with 50+% retrace
            if (f_length [1][0] < 0
            && f_price [1][0] < f_price [1][4]
            && f_price [1][1] > f_price [1][4] + 0.5 * MathAbs (f_length [1][4]) * Point
            && MathAbs (f_length [1][4]) > MathAbs (f_length [1][6])
            && MathAbs (f_length [1][3]) < MathAbs (f_length [1][4])
            && MathAbs (f_length [1][1]) < MathAbs (f_length [1][4])
            && MathAbs (f_length [1][0]) < MathAbs (f_length [1][4]))
                pattern = 3;

        if (pattern > 0){
                order.RefreshFULL ();
                lotToOpen = NormalizeDouble (AccountBalance () / (1000 / 0.5),lotDigits);
                if (lotToOpen < lotMin && lotToOpen > 0) lotToOpen = lotMin;
                if (lotToOpen > lotMax && lotToOpen > 0) lotToOpen = lotMax;
                tp = f_price [f][5];
                sl = f_price [f][4] - 0.5 * (f_price [f][1] - f_price [f][4]);
                log_add_line ("sl="+sl+"   tp="+tp,Red);
                if (order.dealBuy.time_LastOpened_Buy < f_time [f][1]){ 
                    Print ("Opening order BUY: lastopenedtime="+order.dealBuy.time_LastOpened_Buy);
                int mNumber = StringConcatenate (_TYPE_MAIN,f);
                ticket = OrderSend (Symbol(),OP_BUY,lotToOpen,Ask,5,0,0,mNumber,mNumber,0,Blue);
                }
                if (ticket > 0){
                   if (OrderSelect (ticket,SELECT_BY_TICKET,MODE_TRADES)){
                      log_add_line ("ADDING BUY ORDER #"+ticket+" at price "+DoubleToStr (Ask,Digits)+ ". Lot "+lotToOpen,DarkGreen);
                      log_add_line ("pattern ="+pattern,DarkGreen);
                      //order.Add (ticket, OP_BUY, wave.impulse.timeStart, wave.impulse.timeEnd, TimeCurrent ());
                      order.GVSerie_Set (OP_BUY, _SERIE_BASE_LOT, lotToOpen);
                      order.GVSerie_Set (OP_BUY, _SERIE_GRID_START_PRICE, OrderOpenPrice ());
                      order.GVSerie_Set (OP_BUY, _SERIE_GRID_STEP_NUMBER, 1);
                      order.GVSerie_Set (OP_BUY, _SERIE_LAST_CLOSED_PROFIT, 0);
                      order.GV_Set (OrderOpenPrice(), _TP, tp);
                      order.GV_Set (OrderOpenPrice(), _SL, sl);
                      order.GV_Set (OrderOpenPrice(), _LOT_START, lotToOpen);
                      order.RefreshFULL ();
                      }
                   showLog = true;
                   }
                else log_add_line ("ERROR SENDING ORDER BUY at price "+DoubleToStr (Ask,Digits)+". Lot "+lotToOpen+".   Reason: "+ErrorDescription (GetLastError()),Red);
                showLog = true;
                }           
        }
    }
            
            


    




//    // 1. Enter BUY ORDERS
//    for (int f = 2; f >= 1; f--){
//        // 1.1. Flat started after 1-wave impulse order-wise
//        correctorPrice = candle.FindCorrector (5,OP_BUY,f_time [f][4]);
//        if (f_length [f][0] < 0
//        && MathAbs (f_length [f][1]) > costs_pips / deal_costs_max_koef 
//        && MathAbs (f_length [f][1]) > MathAbs (f_length [f][0])
//        && MathAbs (f_length [f][1]) < MathAbs (f_length [f][2])
//        && MathAbs (f_length [f][1]) > 0.66 * MathAbs (f_length [f][2])
//        && MathAbs (f_length [f][0]) > 0.66 * MathAbs (f_length [f][1])
//        && MathAbs (candle.FindMax (timeframe_Main, OP_SELL, f_time [f][3], f_time [f][2], false)) > MathAbs (candle.FindMax (timeframe_Main, OP_SELL, f_time [f][1], f_time [f][0], false))
//        && MathAbs (candle.FindMax (timeframe.Highest (f_time [f][3],f_time [f][2], 2), OP_SELL, f_time [f][3], f_time [f][2], false)) > MathAbs (candle.FindMax (timeframe.Highest (f_time [f][1],f_time [f][0], 2), OP_SELL, f_time [f][1], f_time [f][0], false))
//          ){
//             order.RefreshFast ();
//              if (check_spread ()
//                && order.totals.countBuy == 0
//                ){
//                   lotToOpen = NormalizeDouble (AccountBalance () / (1000 / 0.5),lotDigits);
//                   if (lotToOpen < lotMin && lotToOpen > 0) lotToOpen = lotMin;
//                   if (lotToOpen > lotMax && lotToOpen > 0) lotToOpen = lotMax;
//                   tp = f_price [f][5];
//                   sl = f_price [f][4] - 0.5 * (f_price [f][1] - f_price [f][4]);
//                   log_add_line ("sl="+sl+"   tp="+tp,Red);
//                   ticket = OrderSend (Symbol(),OP_BUY,lotToOpen,Ask,5,0,0,1,1,0,Blue);
//                   if (ticket > 0){
//                      if (OrderSelect (ticket,SELECT_BY_TICKET,MODE_TRADES)){
//                         log_add_line ("ADDING BUY ORDER #"+ticket+" at price "+DoubleToStr (Ask,Digits)+ ". Lot "+lotToOpen,DarkGreen);
//                         //order.Add (ticket, OP_BUY, wave.impulse.timeStart, wave.impulse.timeEnd, TimeCurrent ());
//                         order.GVSerie_Set (OP_BUY, _SERIE_BASE_LOT, lotToOpen);
//                         order.GVSerie_Set (OP_BUY, _SERIE_GRID_START_PRICE, OrderOpenPrice ());
//                         order.GVSerie_Set (OP_BUY, _SERIE_GRID_STEP_NUMBER, 1);
//                         order.GVSerie_Set (OP_BUY, _SERIE_LAST_CLOSED_PROFIT, 0);
//                         order.GV_Set (OrderOpenPrice(), _TP, tp);
//                         order.GV_Set (OrderOpenPrice(), _SL, sl);
//                         order.GV_Set (OrderOpenPrice(), _LOT_START, lotToOpen);
//                         order.RefreshFULL ();
//                         }
//                      showLog = true;
//                      }
//                   else log_add_line ("ERROR SENDING ORDER BUY at price "+DoubleToStr (Ask,Digits)+". Lot "+lotToOpen+".   Reason: "+ErrorDescription (GetLastError()),Red);
//                   showLog = true;
//                   }           
//          }
//    }
    log_add_line ("f_length [1][0]="+f_length[1][0]+"   f_length [1][1]="+f_length[1][1]+"   f_length [1][2]="+f_length[1][2]+"   f_length [1][3]="+f_length[1][3]+"   f_length [1][4]="+f_length[1][4]+"   f_length [1][5]="+f_length[1][5]+"   f_length [1][6]="+f_length[1][6]+"   f_length [1][7]="+f_length[1][7]+"   f_length [1][8]="+f_length[1][8],Blue);
    log_add_line ("f_length [1][35]="+f_length[1][35]+"   f_length [1][34]="+f_length[1][34]+"   f_length [1][33]="+f_length[1][33]+"   f_length [1][32]="+f_length[1][32],Blue);
    log_add_line ("f_outs [1][0]="+f_outsideswing [1][0]+"   f_outs [1][1]="+f_outsideswing [1][1]+"   f_outs [1][2]="+f_outsideswing [1][2]+"   f_outs [1][3]="+f_outsideswing [1][3]+"   f_outs [1][4]="+f_outsideswing [1][4]+"   f_outs [1][5]="+f_outsideswing [1][5]+"   f_outs [1][6]="+f_outsideswing [1][6],Blue);
    
    log_add_line ("f_length [2][0]="+f_length[2][0]+"   f_length [2][1]="+f_length[2][1]+"   f_length [2][2]="+f_length[2][2]+"   f_length [2][3]="+f_length[2][3]+"   f_length [2][4]="+f_length[2][4]+"   f_length [2][5]="+f_length[2][5]+"   f_length [2][6]="+f_length[2][6]+"   f_length [2][7]="+f_length[2][7]+"   f_length [2][8]="+f_length[2][8],Blue);
    log_add_line ("f_length [2][35]="+f_length[2][35]+"   f_length [2][34]="+f_length[2][34]+"   f_length [2][33]="+f_length[2][33]+"   f_length [2][32]="+f_length[2][32],Blue);
    log_add_line ("f_outs [2][0]="+f_outsideswing [2][0]+"   f_outs [2][1]="+f_outsideswing [2][1]+"   f_outs [2][2]="+f_outsideswing [2][2]+"   f_outs [2][3]="+f_outsideswing [2][3]+"   f_outs [2][4]="+f_outsideswing [2][4]+"   f_outs [2][5]="+f_outsideswing [2][5]+"   f_outs [2][6]="+f_outsideswing [2][6],Blue);
    
    log_add_line ("f_length [3][0]="+f_length[3][0]+"   f_length [3][1]="+f_length[3][1]+"   f_length [3][2]="+f_length[3][2]+"   f_length [3][3]="+f_length[3][3]+"   f_length [3][4]="+f_length[3][4]+"   f_length [3][5]="+f_length[3][5]+"   f_length [3][6]="+f_length[3][6]+"   f_length [3][7]="+f_length[3][7]+"   f_length [3][8]="+f_length[3][8],Blue);
    log_add_line ("f_length [3][35]="+f_length[3][35]+"   f_length [3][34]="+f_length[3][34]+"   f_length [3][33]="+f_length[3][33]+"   f_length [3][32]="+f_length[3][32],Blue);
    log_add_line ("f_outs [3][0]="+f_outsideswing [3][0]+"   f_outs [3][1]="+f_outsideswing [3][1]+"   f_outs [3][2]="+f_outsideswing [3][2]+"   f_outs [3][3]="+f_outsideswing [3][3]+"   f_outs [3][4]="+f_outsideswing [3][4]+"   f_outs [3][5]="+f_outsideswing [3][5]+"   f_outs [3][6]="+f_outsideswing [3][6],Blue);
    
    log_add_line ("f_length [4][0]="+f_length[4][0]+"   f_length [4][1]="+f_length[4][1]+"   f_length [4][2]="+f_length[4][2]+"   f_length [4][3]="+f_length[4][3]+"   f_length [4][4]="+f_length[4][4]+"   f_length [4][5]="+f_length[4][5]+"   f_length [4][6]="+f_length[4][6]+"   f_length [4][7]="+f_length[4][7]+"   f_length [4][8]="+f_length[4][8],Blue);
    log_add_line ("f_length [4][35]="+f_length[4][35]+"   f_length [4][34]="+f_length[4][34]+"   f_length [4][33]="+f_length[4][33]+"   f_length [4][32]="+f_length[4][32],Blue);
    log_add_line ("f_outs [4][0]="+f_outsideswing [4][0]+"   f_outs [4][1]="+f_outsideswing [4][1]+"   f_outs [4][2]="+f_outsideswing [4][2]+"   f_outs [4][3]="+f_outsideswing [4][3]+"   f_outs [4][4]="+f_outsideswing [4][4]+"   f_outs [4][5]="+f_outsideswing [4][5]+"   f_outs [4][6]="+f_outsideswing [4][6],Blue);

    log_add_line ("f_length [5][0]="+f_length[5][0]+"   f_length [5][1]="+f_length[5][1]+"   f_length [5][2]="+f_length[5][2]+"   f_length [5][3]="+f_length[5][3]+"   f_length [5][4]="+f_length[5][4]+"   f_length [5][5]="+f_length[5][5]+"   f_length [5][6]="+f_length[5][6]+"   f_length [5][7]="+f_length[5][7]+"   f_length [5][8]="+f_length[5][8],Blue);
    log_add_line ("f_length [5][35]="+f_length[5][35]+"   f_length [5][34]="+f_length[5][34]+"   f_length [5][33]="+f_length[5][33]+"   f_length [5][32]="+f_length[5][32],Blue);
    log_add_line ("f_outs [5][0]="+f_outsideswing [5][0]+"   f_outs [5][1]="+f_outsideswing [5][1]+"   f_outs [5][2]="+f_outsideswing [5][2]+"   f_outs [5][3]="+f_outsideswing [5][3]+"   f_outs [5][4]="+f_outsideswing [5][4]+"   f_outs [5][5]="+f_outsideswing [5][5]+"   f_outs [5][6]="+f_outsideswing [5][6],Blue);
    
   
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
  

