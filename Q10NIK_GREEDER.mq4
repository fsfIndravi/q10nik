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

   showLog = false;
   
   logLineCount = 0;
   
   spread = MarketInfo (Symbol (),MODE_SPREAD);
   
   if (GlobalVariableGet ("gv_show_log") == 1) showLog = true;
   
   costs_set ();
   
//   _positions_close ();

   if (TimeCurrent () - time_start < skiphours * 3600) return (0);
   
   if (OrdersTotal () > 0) return (0);
   
   _positions_close ();
   
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
//  FID?45: ������� ����������� ��� ����������� ������
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
   
//   for (int orders = 1; orders <= order.totals.count; orders++){
//      
//      // 1. Closing order in BE
//      
//      if (order.positions[orders].direction == OP_BUY
//         && order.positions[orders].profit >= order.getCarrier
//         
//   }
   
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
    double  correctorPrice;
   
    arrays (1,1);
    arrays (1,2);
    
    // 1. Enter BUY ORDERS

    for (int f = 2; f >= 1; f--){
        // 1.1. Flat started after 1-wave impulse order-wise
        correctorPrice = candle.FindCorrector (1,OP_BUY,f_time [f][4]);
        if (f_length [f][0] < 0
        //&& MathAbs (f_length [f][4]) > f_length_avg [f]
        && MathAbs (f_length [f][3]) >= 0.5 * MathAbs (f_length [f][4])
        && f_price [f][1] < f_price [f][5]
        && f_price [f][3] < f_price [f][5]
        && f_price [f][2] > f_price [f][4]
        && f_price [f][1] > f_price [f][3]
        && ((f_price [f][2] > correctorPrice && f_price [f][0] < correctorPrice) 
            || (f_price [f][2] <= correctorPrice && f_price [f][0] < f_price [f][4])) 
        && MathAbs (candle.FindMax (timeframe_Main, OP_SELL, f_time [f][5], f_time [f][4], true)) > MathAbs (candle.FindMax (timeframe_Main, OP_SELL, f_time [f][3], f_time [f][0], true))
        && MathAbs (candle.FindMax (timeframe.Highest (f_time [f][5],f_time [f][4], 2), OP_SELL, f_time [f][5], f_time [f][4], false)) > MathAbs (candle.FindMax (timeframe.Highest (f_time [f][3],f_time [f][0], 2), OP_SELL, f_time [f][3], f_time [f][0], false))
          
          ){
          
             order.RefreshFast ();
              if (check_spread ()
                && order.totals.countBuy == 0
                ){
                   lotToOpen = NormalizeDouble (AccountBalance () / (1000 / 0.5),lotDigits);
                   if (lotToOpen < lotMin && lotToOpen > 0) lotToOpen = lotMin;
                   if (lotToOpen > lotMax && lotToOpen > 0) lotToOpen = lotMax;
                   tp = f_price [f][5];
                   sl = f_price [f][4] - 0.5 * (f_price [f][1] - f_price [f][4]);
                   log_add_line ("sl="+sl+"   tp="+tp,Red);
                   ticket = OrderSend (Symbol(),OP_BUY,lotToOpen,Ask,5,0,0,1,1,0,Blue);
                   if (ticket > 0){
                      if (OrderSelect (ticket,SELECT_BY_TICKET,MODE_TRADES)){
                         log_add_line ("ADDING BUY ORDER #"+ticket+" at price "+DoubleToStr (Ask,Digits)+ ". Lot "+lotToOpen,DarkGreen);
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
      // ���������� ��������� ��� ��������� ����
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
   
