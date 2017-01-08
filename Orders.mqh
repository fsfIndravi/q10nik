//+------------------------------------------------------------------+
//| BEST IN CLASS 'ORDERS' CLASS :)))                                |
//+------------------------------------------------------------------+

// Defining Global variables

double   tickValue; 
int      spread;
int      spread_max;
int      spread_avg;
int      spreadArray[10];
double   commission;
double   commissionPips;
double   costs;
int      costs_pips;

// Defining constants
   #define _IMPULSE_TIME_START 1
   #define _IMPULSE_TIME_END 2
   #define _CLOSED_NUMBER 3
   #define _CLOSED_BE 4
   #define _CLOSED_SL 5
   #define _LOT_START 6
   #define _TP 7
   #define _SL 8
   #define _DEAL_ID 9
   #define _TYPE 10                  // 1 - Base. 2 - Add. 3 - Lock. 4 - Repair
   #define _DRIVER_TIME 11
   #define _DRIVER_TIMEFRAME 12
   #define _SERIE_BASE_LOT 13
   #define _SERIE_LAST_HIGH_TIME 14
   #define _SERIE_LAST_LOW_TIME 15
   #define _SERIE_LAST_HIGH_PRICE 16
   #define _SERIE_LAST_LOW_PRICE 17
   #define _SERIE_LAST_CLOSED_PROFIT 18
   #define _SERIE_GRID_STEP_NUMBER 19
   #define _SERIE_GRID_START_PRICE 20
   #define _SERIE_GRID_STEP_LENGTH 21
   
   // Order types constants
   #define _TYPE_MAIN    1
   #define _TYPE_ADD     2
   #define _TYPE_LOCK    3
   #define _TYPE_REPAIR  4

class OrdersClass {

private:
   int            deals_count;
   int            lastReinitTime;
   double         commissionPips;
   double         tickValue;
public:
   // Orders data structure
   struct ordersArray{
      int         ticket;
      int         direction;              // OP_BUY - buy, OP_SELL - sell
      int         dealID;
      int         openTime;
      double      openPrice;
      string      symbol;
      int         type;                   // 1 - Base. 2 - Add. 3. Lock. 4. Repair
      double      lot;
      double      lotStart;               // Order start lot
      int         magic;
      int         duration;
      double      profit;
      int         pips;
      double      tp;
      double      sl;     
      bool        closedPartially;
      double      closedBE;                // Closed on Break Even flag
      double      closedSL;                // Closed on Stop Loss flag
      double      closedNumber;            // How many time the order was closed partially
      double      impulseTimeStart;       // Time of the highest/lowest of the impulse wave of the order
      double      impulseTimeEnd;         // Time of the highest/lowest of the impulse wave of the order
   };
   
   struct ordersTotals{
      int         count;
      int         countBuy;
      int         countSell;
      double      lots;
      double      lotsBuy;
      int         lotsSell;
      double      profit;
      double      profitBuy;
      double      profitSell;
   };
   
   struct dealsArray{
      int         ID;
      int         direction;                 // OP_BUY || OP_SELL
      int         time_Start;
      int         time_LastOpened_Buy;
      int         time_LastOpened_Sell;
      int         time_LastHigh;
      int         time_LastLow;
      double      price_TP1;
      double      price_TP2;
      double      price_TP3;
      double      price_BE;
      int         countOrders_Total;
      int         countOrders_Buy;
      int         countOrders_Sell;
      double      lot_Total;
      double      lot_Buy;
      double      lot_Sell;
      double      profit_Total;
      double      profit_Buy;
      double      profit_Sell;
      double      profit_Closed_Total;
      double      profit_Closed_Buy;
      double      profit_Closed_Sell;
   };
   
   struct carrierWaveStruct {
      int         timeStart;
      int         timeEnd;
      double      priceStart;
      double      priceEnd;
      double      length;
      int         duration;
   };
    
   // Class functions

   double Serie_BE_Set (int directionLocal, double commissionPips, double tickValue, ordersTotals &totals, ordersArray &positions[]);

   double Serie_BE_New (int directionLocal, double newPriceLocal, double newLotLocal, double commissionPips, double tickValue);

   void Serie_SL_Set (int directionLocal, double newSLPriceLocal);

   void Delete (int ticket);
   
   void Add (int ticket, int orderDirection, int waveTimeStart, int waveTimeEnd, int driverTime);
   
   // updating profit info only
   void RefreshFast ();       // Refreshes orders profit/totals (faster)
   
   // full update
   void RefreshFULL ();       // Refreshes all orders data (slower)
   
   // return Deal ID profit (including closed orders with the same dealID)
   double DealProfitTotal (int d_dealID);
   
   // Setting Global variables
   void GV_Set (double s_openPrice, int s_type, double s_value);
   
   // Getting Global variable
   double GV_Get (double g_openPrice, int g_type);
   
   // Clearing ALL Global variables that are used with orders
   void GV_ClearALL ();
   
   // Deleting Global variables if they are not linked to open orders
   void GV_Clean ();
   
   // Setting Serie GV   
   void GVSerie_Set (int s_direction, int s_type, double s_value);
   
   // Getting Serie GV   
   double GVSerie_Get (int s_direction, int s_type);
   
   // Send Limit order
   void LimitSend (int l_direction, double l_price, double l_tp, double l_sl, int l_expiration);
   
   // Delete Limit order
   void LimitDelete (int d_ticket, double d_priceOpen);
   
   // Getting deal ID for a new order
   int ID_GetNew (int n_direction);
   
   // Delete deal
   void DealDelete (int d_direction);
   
   // Draw history
   void HistoryDraw ();
   
   // Delete History
   void HistoryDelete ();
   
   // Draw Label
   void LabelDraw (int orderTicket_d1, int direction_d1, double orderOpenPrice_d1, int orderOpenTime_d1, string labelText_d1, color d_labelColor_d1);
   
   // Delete Label
   void LabelDelete ();
   
   // Draw labels
   void LabelsDraw ();

   // Costs set


   
   
   // Loading structures   
   ordersArray positions[99];
   ordersTotals totals;
   dealsArray dealBuy;
   dealsArray dealSell;
      
  };




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OrdersClass::RefreshFULL (){   // Refreshes full
   int a_count = 0;
   double totalProfitBuy = 0;
   double totalProfitSell = 0;
   double totalProfit = 0;
   DealDelete (OP_BUY);
   DealDelete (OP_SELL);
   for (int a_pos = 0; a_pos <= OrdersTotal ()-1; a_pos++){
      if (OrderSelect (a_pos, SELECT_BY_POS, MODE_TRADES)){
         if (OrderSymbol () == Symbol () 
         && (OrderType () == OP_BUY || OrderType () == OP_SELL)
         && OrderMagicNumber () > 0){
            a_count++;
            positions[a_count].closedPartially = false;
            if (OrderType () == OP_BUY) {
               positions[a_count].direction = OP_BUY;
               positions[a_count].pips = Bid - OrderOpenPrice ();
            }
            if (OrderType () == OP_SELL){
               positions[a_count].direction = OP_SELL;
               positions[a_count].pips = OrderOpenPrice () - Ask;
            }
            positions[a_count].duration            = TimeCurrent () - OrderOpenTime ();
            positions[a_count].lot                 = OrderLots ();
            positions[a_count].magic               = OrderMagicNumber ();
            positions[a_count].openPrice           = OrderOpenPrice ();
            positions[a_count].type                = StrToInteger (StringSubstr (positions[a_count].magic,0,1));
            positions[a_count].dealID              = StrToInteger (StringSubstr (positions[a_count].magic, StringLen (positions[a_count].magic)-5,5));
            positions[a_count].openTime            = OrderOpenTime ();
            positions[a_count].profit              = OrderProfit () + OrderCommission () + OrderSwap ();
            positions[a_count].sl                  = OrderStopLoss ();
            positions[a_count].symbol              = OrderSymbol ();
            positions[a_count].ticket              = OrderTicket ();
            positions[a_count].tp                  = OrderTakeProfit ();
            positions[a_count].impulseTimeStart    = GV_Get (OrderOpenPrice (), _IMPULSE_TIME_START);
            positions[a_count].impulseTimeEnd      = GV_Get (OrderOpenPrice (), _IMPULSE_TIME_END);
            positions[a_count].closedBE            = GV_Get (OrderOpenPrice (), _CLOSED_BE);
            positions[a_count].closedSL            = GV_Get (OrderOpenPrice (), _CLOSED_SL);
            positions[a_count].closedNumber        = GV_Get (OrderOpenPrice (), _CLOSED_NUMBER);
            positions[a_count].lotStart            = GV_Get (OrderOpenPrice (), _LOT_START);
            if (positions[a_count].lotStart > positions[a_count].lot) positions[a_count].closedPartially = true;  // Check partial closing
            totalProfit += positions[a_count].profit;                                  
            if (positions[a_count].direction == OP_BUY)  totalProfitBuy += positions[a_count].profit;
            if (positions[a_count].direction == OP_SELL) totalProfitSell += positions[a_count].profit;
            // BUY deals
            if ((positions[a_count].type == _TYPE_MAIN && positions[a_count].direction == OP_BUY)
            || (positions[a_count].type == _TYPE_ADD && positions[a_count].direction == OP_BUY)
            || (positions[a_count].type == _TYPE_REPAIR && positions[a_count].direction == OP_BUY)
            || (positions[a_count].type == _TYPE_LOCK && positions[a_count].direction == OP_SELL)){
               dealBuy.direction       = OP_BUY;
               dealBuy.ID              = positions[a_count].dealID;
               dealBuy.countOrders_Total++;
               dealBuy.lot_Total       += positions[a_count].lot;
               if (positions[a_count].direction == OP_BUY){
                  dealBuy.countOrders_Buy++;
                  dealBuy.lot_Buy += positions[a_count].lot;
                  dealBuy.profit_Buy += positions[a_count].profit;
                  if (dealBuy.time_LastHigh < positions[a_count].impulseTimeEnd) dealBuy.time_LastHigh = positions[a_count].impulseTimeEnd;
                  if (dealBuy.time_LastOpened_Buy < positions[a_count].openTime) dealBuy.time_LastOpened_Buy = positions[a_count].openTime;
               }
               if (positions[a_count].direction == OP_SELL){
                  dealBuy.countOrders_Sell++;
                  dealBuy.lot_Sell += positions[a_count].lot;
                  dealBuy.profit_Sell += positions[a_count].profit;
               }
            }
            // SELL deals
            if ((positions[a_count].type == _TYPE_MAIN && positions[a_count].direction == OP_SELL)
            || (positions[a_count].type == _TYPE_ADD && positions[a_count].direction == OP_SELL)
            || (positions[a_count].type == _TYPE_REPAIR && positions[a_count].direction == OP_SELL)
            || (positions[a_count].type == _TYPE_LOCK && positions[a_count].direction == OP_BUY)){
               dealSell.direction       = OP_SELL;
               dealSell.ID              = positions[a_count].dealID;
               dealSell.countOrders_Total++;
               dealSell.lot_Total       += positions[a_count].lot;
               if (positions[a_count].direction == OP_SELL){
                  dealSell.countOrders_Sell++;
                  dealSell.lot_Sell += positions[a_count].lot;
                  dealSell.profit_Sell += positions[a_count].profit;
                  if (dealSell.time_LastLow > positions[a_count].impulseTimeEnd || dealSell.time_LastLow == 0) dealSell.time_LastLow = positions[a_count].impulseTimeEnd;
                  if (dealSell.time_LastOpened_Sell < positions[a_count].openTime) dealSell.time_LastOpened_Sell = positions[a_count].openTime;
               }
               if (positions[a_count].direction == OP_BUY){
                  dealSell.countOrders_Buy++;
                  dealSell.lot_Buy += positions[a_count].lot;
                  dealSell.profit_Buy += positions[a_count].profit;
               }
            }
         }
      }
   }
   // Setting totals
   totals.count = a_count;
   if (dealBuy.ID > 0) dealBuy.profit_Total = DealProfitTotal (dealBuy.ID);
   if (dealSell.ID > 0) dealSell.profit_Total = DealProfitTotal (dealSell.ID);
}
   




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OrdersClass::Delete (int ticketLocal)
   {
   
   
   
   }



//+------------------------------------------------------------------+
//| Adding new order parameters to the orders array
//+------------------------------------------------------------------+

OrdersClass::Add (int ticketLocal, int orderDirection, int waveTimeStartLocal, int waveTimeEndLocal, int driverTime){
   if (OrderSelect (ticketLocal, SELECT_BY_TICKET, MODE_TRADES)){
      GV_Set (OrderOpenPrice (), _IMPULSE_TIME_START, waveTimeStartLocal);
      GV_Set (OrderOpenPrice (), _IMPULSE_TIME_END, waveTimeEndLocal);
      GV_Set (OrderOpenPrice (), _CLOSED_BE, 0);
      GV_Set (OrderOpenPrice (), _CLOSED_SL, 0);
      GV_Set (OrderOpenPrice (), _CLOSED_NUMBER, 0);
      GV_Set (OrderOpenPrice (), _LOT_START, OrderLots());
      GV_Set (OrderOpenPrice (), _DRIVER_TIME, driverTime);
      RefreshFULL ();
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

OrdersClass::RefreshFast (){
   totals.count = 0;
   totals.countBuy = 0;
   totals.countSell = 0;
   totals.profit = 0;
   totals.profitBuy = 0;
   totals.profitSell = 0;
   for (int r_ord = 0; r_ord <= OrdersTotal (); r_ord++){
      if (OrderSelect (r_ord, SELECT_BY_POS, MODE_TRADES)
      && OrderSymbol () == Symbol ()
      && (OrderType () == OP_BUY || OrderType () == OP_SELL)
      && OrderMagicNumber () >0){
         totals.count++;
         positions[totals.count].profit = OrderProfit () + OrderCommission () + OrderSwap ();
         positions[totals.count].duration = TimeCurrent () - OrderOpenTime ();
         totals.profit += positions[totals.count].profit;
         if (OrderType () == OP_BUY){
            totals.profitBuy += positions[totals.count].profit;
            totals.countBuy++;
         }
         if (OrderType () == OP_SELL){
            totals.profitSell += positions[totals.count].profit;
            totals.countSell++;
         }
      }
   }
}



//+------------------------------------------------------------------+
//| Calculating Deal Profit                                          |
//+------------------------------------------------------------------+

double OrdersClass::DealProfitTotal (int d_dealID){
   double result_profit = 0;
   for (int pos = 0; pos <= OrdersHistoryTotal()-1; pos++){
      if (TimeCurrent () - OrderOpenTime () >= 2592000) break;
      if (OrderSelect (pos,SELECT_BY_POS,MODE_HISTORY) 
      && OrderSymbol () == Symbol()
      && StringToInteger (StringSubstr (OrderMagicNumber (),2,5)) == d_dealID){
         result_profit += (OrderProfit () + OrderCommission () + OrderSwap ());
      }
   }
   for (pos = 0; pos <= OrdersTotal ()-1; pos++){
      if (OrderSelect (pos,SELECT_BY_POS,MODE_TRADES)
      && OrderSymbol () == Symbol()
      && StringToInteger (StringSubstr (OrderMagicNumber (),2,5)) == d_dealID){
         result_profit += (OrderProfit () + OrderCommission () + OrderSwap ());
      }
   }
   return (result_profit);
}
   



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrdersClass::GV_Set (double s_openPrice, int s_type, double s_value){
   string name;
   if (s_type == _IMPULSE_TIME_END){
      name = StringConcatenate ("ITE_",StringSubstr (s_openPrice,StringLen (s_openPrice)-5,5));
      GlobalVariableSet (name,s_value);
   }
   if (s_type == _CLOSED_BE){
      name = StringConcatenate ("CBE_",StringSubstr (s_openPrice,StringLen (s_openPrice)-5,5));
      GlobalVariableSet (name,s_value);
   }
   if (s_type == _CLOSED_NUMBER){
      name = StringConcatenate ("CNM_",StringSubstr (s_openPrice,StringLen (s_openPrice)-5,5));
      GlobalVariableSet (name,s_value);
   }
   if (s_type == _CLOSED_SL){
      name = StringConcatenate ("CSL_",StringSubstr (s_openPrice,StringLen (s_openPrice)-5,5));
      GlobalVariableSet (name,s_value);
   }
   if (s_type == _LOT_START){
      name = StringConcatenate ("LST_",StringSubstr (s_openPrice,StringLen (s_openPrice)-5,5));
      GlobalVariableSet (name,s_value);
   }
   if (s_type == _DRIVER_TIME){
      name = StringConcatenate ("DTM_",StringSubstr (s_openPrice,StringLen (s_openPrice)-5,5));
      GlobalVariableSet (name,s_value);
   }
   if (s_type == _DRIVER_TIMEFRAME){
      name = StringConcatenate ("DTF_",StringSubstr (s_openPrice,StringLen (s_openPrice)-5,5));
      GlobalVariableSet (name,s_value);
   }
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double OrdersClass::GV_Get (double g_openPrice, int g_type){
   string name;
   if (g_type == _IMPULSE_TIME_END){
      name = StringConcatenate ("ITE_",StringSubstr (g_openPrice,StringLen (g_openPrice)-5,5));
      return (GlobalVariableGet (name));
   }
   if (g_type == _CLOSED_BE){
      name = StringConcatenate ("CBE_",StringSubstr (g_openPrice,StringLen (g_openPrice)-5,5));
      return (GlobalVariableGet (name));
   }
   if (g_type == _CLOSED_NUMBER) {
      name = StringConcatenate ("CLN_",StringSubstr (g_openPrice,StringLen (g_openPrice)-5,5));
      return (GlobalVariableGet (name));
   }
   if (g_type == _CLOSED_SL){
      name = StringConcatenate ("CSL_",StringSubstr (g_openPrice,StringLen (g_openPrice)-5,5));
      return (GlobalVariableGet (name));
   }
   if (g_type == _LOT_START){
      name = StringConcatenate ("LST_",StringSubstr (g_openPrice,StringLen (g_openPrice)-5,5));
      return (GlobalVariableGet (name));
   }
   if (g_type == _DRIVER_TIME){
      name = StringConcatenate ("DTM_",StringSubstr (g_openPrice,StringLen (g_openPrice)-5,5));
      return (GlobalVariableGet (name));
   }
   if (g_type == _DRIVER_TIMEFRAME){
      name = StringConcatenate ("DTF_",StringSubstr (g_openPrice,StringLen (g_openPrice)-5,5));
      return (GlobalVariableGet (name));
   }
   return (-1);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrdersClass::GV_ClearALL (){
   for (int x = GlobalVariablesTotal (); x >= 0; x--){
      if (StringSubstr (GlobalVariableName (x),0,3) == "ITE"
      || StringSubstr (GlobalVariableName (x),0,3) == "CBE"
      || StringSubstr (GlobalVariableName (x),0,3) == "CLN"
      || StringSubstr (GlobalVariableName (x),0,3) == "CSL"
      || StringSubstr (GlobalVariableName (x),0,3) == "LST"
      || StringSubstr (GlobalVariableName (x),0,3) == "DRT"){
         GlobalVariableDel (GlobalVariableName (x));
      }
   }
}
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrdersClass::GV_Clean (){
   
   // Check & Clean Global variables every hour
   
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int OrdersClass::ID_GetNew (int n_direction){
   int id_int;
   if (n_direction == OP_BUY){
      if (dealBuy.lot_Total > 0) return (dealBuy.ID);
   }
   if (n_direction == OP_SELL){
      if (dealSell.lot_Total > 0) return (dealSell.ID);
   }
   id_int = StrToInteger (StringSubstr (TimeCurrent (), StringLen (TimeCurrent())-5,5));
   return (id_int);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrdersClass::DealDelete (int d_direction){
   if (d_direction == OP_BUY){
      dealBuy.ID                       = 0;
      dealBuy.direction                = 0;
      dealBuy.time_Start               = 0;
      dealBuy.time_LastOpened_Buy      = 0;
      dealBuy.time_LastOpened_Sell     = 0;
      dealBuy.time_LastHigh            = 0;
      dealBuy.time_LastLow             = 0;
      dealBuy.price_TP1                = 0;
      dealBuy.price_TP2                = 0;
      dealBuy.price_TP3                = 0;
      dealBuy.price_BE                 = 0;
      dealBuy.countOrders_Total        = 0;
      dealBuy.countOrders_Buy          = 0;
      dealBuy.countOrders_Sell         = 0;
      dealBuy.lot_Total                = 0;
      dealBuy.lot_Buy                  = 0;
      dealBuy.lot_Sell                 = 0;
      dealBuy.profit_Total             = 0;
      dealBuy.profit_Buy               = 0;
      dealBuy.profit_Sell              = 0;
      dealBuy.profit_Closed_Total      = 0;
      dealBuy.profit_Closed_Buy        = 0;
      dealBuy.profit_Closed_Sell       = 0;
   }   
   if (d_direction == OP_SELL){
      dealSell.ID                       = 0;
      dealSell.direction                = 0;
      dealSell.time_Start               = 0;
      dealSell.time_LastOpened_Buy      = 0;
      dealSell.time_LastOpened_Sell     = 0;
      dealSell.time_LastHigh            = 0;
      dealSell.time_LastLow             = 0;
      dealSell.price_TP1                = 0;
      dealSell.price_TP2                = 0;
      dealSell.price_TP3                = 0;
      dealSell.price_BE                 = 0;
      dealSell.countOrders_Total        = 0;
      dealSell.countOrders_Buy          = 0;
      dealSell.countOrders_Sell         = 0;
      dealSell.lot_Total                = 0;
      dealSell.lot_Buy                  = 0;
      dealSell.lot_Sell                 = 0;
      dealSell.profit_Total             = 0;
      dealSell.profit_Buy               = 0;
      dealSell.profit_Sell              = 0;
      dealSell.profit_Closed_Total      = 0;
      dealSell.profit_Closed_Buy        = 0;
      dealSell.profit_Closed_Sell       = 0;
   }

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrdersClass::HistoryDraw (){
   string nameArrowOpen;
   string nameArrowClose;
   string nameLine;
   int ticketLocal;
   int pipsLocal;
   int orderCode;
   double h_tickValue = MarketInfo (Symbol(), MODE_TICKVALUE);
   for (int t = OrdersHistoryTotal(); t>=0; t--){
      if (OrderSelect (t,SELECT_BY_POS,MODE_HISTORY) == true){
         if (OrderMagicNumber () > 0 && OrderSymbol () == Symbol ()){
            orderCode = OrderMagicNumber ();
            ticketLocal = OrderTicket ();
            if (OrderLots () != 0 && h_tickValue != 0) pipsLocal = NormalizeDouble (OrderProfit () / OrderLots () / h_tickValue,0);
            if (OrderType () == OP_BUY){
               nameArrowOpen = StringConcatenate ("OPEN BUY "+orderCode+" #",ticketLocal," ",OrderLots()," ",OrderSymbol()," Pips:",pipsLocal);
               nameArrowClose = StringConcatenate ("CLOSE BUY "+orderCode+" #",ticketLocal," ",OrderLots()," ",OrderSymbol()," Pips:",pipsLocal);
               nameLine = StringConcatenate ("LINE BUY "+orderCode+" #",ticketLocal," ",OrderLots()," ",OrderSymbol()," Pips:",pipsLocal);
               DrawArrow (nameArrowOpen, 1, Blue, OrderOpenTime(), OrderOpenPrice());
               DrawArrow (nameArrowClose, 3, Orange, OrderCloseTime(), OrderClosePrice());
               draw_line (nameLine, Blue, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderClosePrice());
            }
            if (OrderType () == OP_SELL){
               nameArrowOpen = StringConcatenate ("OPEN SELL "+orderCode+" #",ticketLocal," ",OrderLots()," ",OrderSymbol()," Pips:",pipsLocal);
               nameArrowClose = StringConcatenate ("CLOSE SELL "+orderCode+" #",ticketLocal," ",OrderLots()," ",OrderSymbol()," Pips:",pipsLocal);
               nameLine = StringConcatenate ("LINE SELL "+orderCode+" #",ticketLocal," ",OrderLots()," ",OrderSymbol()," Pips:",pipsLocal);
               DrawArrow (nameArrowOpen, 2, Red, OrderOpenTime(), OrderOpenPrice());
               DrawArrow (nameArrowClose, 3, Orange, OrderCloseTime(), OrderClosePrice());
               draw_line (nameLine, Red, OrderOpenTime(), OrderOpenPrice(), OrderCloseTime(), OrderClosePrice());
               
            }
         }
      }
   }
}




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void DrawArrow (string d_name_local, int d_type_arrow, color d_color_arrow, datetime d_time_local, double d_price_local){
   ObjectCreate(d_name_local, OBJ_ARROW, 0, d_time_local, d_price_local);
   ObjectSet(d_name_local, OBJPROP_ARROWCODE, d_type_arrow);
   ObjectSet(d_name_local, OBJPROP_COLOR, d_color_arrow);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void draw_line (string name_local, color color_line, datetime time_open_local, double price_open_local, datetime time_close_local, double price_close_local){
    ObjectCreate(name_local, OBJ_TREND, 0, time_open_local, price_open_local, time_close_local, price_close_local);
    ObjectSet(name_local, OBJPROP_STYLE, STYLE_DOT); 
    ObjectSet(name_local, OBJPROP_WIDTH, 1);
    ObjectSet(name_local, OBJPROP_RAY, false);
    ObjectSet(name_local, OBJPROP_COLOR, color_line);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void delete_objects_by_namePart (string namePartLocal){
   for (int pos = ObjectsTotal (); pos >=0; pos--){      
      if (StringSubstr (ObjectName (pos),0,StringLen (namePartLocal)) == namePartLocal) ObjectDelete (ObjectName (pos));
   }   
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrdersClass::HistoryDelete (){
   delete_objects_by_namePart ("REVERSE BUY");
   delete_objects_by_namePart ("TREND BUY");
   delete_objects_by_namePart ("LOCK BUY");
   delete_objects_by_namePart ("REVERSE SELL");
   delete_objects_by_namePart ("TREND SELL");
   delete_objects_by_namePart ("LOCK SELL");
   delete_objects_by_namePart ("#");
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrdersClass::LabelDraw (int orderTicket_d1, int direction_d1, double orderOpenPrice_d1, int orderOpenTime_d1, string labelText_d1, color d_labelColor_d1){
   string objName = StringConcatenate ("OrderLabel_",orderTicket_d1);
   string objArrowName = StringConcatenate ("OrderArrow_",orderTicket_d1);
   int typeArrow = 2;
   if (ObjectFind (objName) != 0){
      ObjectCreate (objName, OBJ_TEXT, 0, orderOpenTime_d1, orderOpenPrice_d1);
      ObjectSetText(objName, labelText_d1, 20, "Arial", d_labelColor_d1);
      ObjectCreate(objArrowName, OBJ_ARROW, 0, orderOpenTime_d1, orderOpenPrice_d1);
      ObjectSet(objArrowName, OBJPROP_ARROWCODE, typeArrow); 
      ObjectSet(objArrowName, OBJPROP_COLOR, d_labelColor_d1);
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OrdersClass::GVSerie_Set (int s_direction, int s_type, double s_value){
   string name;
   if (s_type == _SERIE_BASE_LOT){
      if (s_direction == OP_BUY) name = "SERIE_BASE_LOT_BUY";
      if (s_direction == OP_SELL) name = "SERIE_BASE_LOT_SEL";
      GlobalVariableSet (name, s_value);
      return;
   }
   if (s_type == _SERIE_LAST_CLOSED_PROFIT){
      if (s_direction == OP_BUY) name = "SERIE_LAST_CLOSED_PROFIT_BUY";
      if (s_direction == OP_SELL) name = "SERIE_LAST_CLOSED_PROFIT_SEL";
      GlobalVariableSet (name, s_value);
      return;
   }
   if (s_type == _SERIE_LAST_CLOSED_PROFIT){
      if (s_direction == OP_BUY) name = "SERIE_LAST_CLOSED_PROFIT_BUY";
      if (s_direction == OP_SELL) name = "SERIE_LAST_CLOSED_PROFIT_SEL";
      GlobalVariableSet (name, s_value);
      return;
   }
   if (s_type == _SERIE_GRID_STEP_NUMBER){
      if (s_direction == OP_BUY) name = "SERIE_GRID_STEP_NUMBER_BUY";
      if (s_direction == OP_SELL) name = "SERIE_GRID_STEP_NUMBER_SELL";
      GlobalVariableSet (name, s_value);
      return;
   }
   if (s_type == _SERIE_GRID_START_PRICE){
      if (s_direction == OP_BUY) name = "SERIE_GRID_START_PRICE_BUY";
      if (s_direction == OP_SELL) name = "SERIE_GRID_START_PRICE_SELL";
      GlobalVariableSet (name, s_value);
      return;
   }
   if (s_type == _SERIE_GRID_STEP_LENGTH){
      if (s_direction == OP_BUY) name = "SERIE_GRID_STEP_LENGTH_BUY";
      if (s_direction == OP_SELL) name = "SERIE_GRID_STEP_LENGTH_SELL";
      GlobalVariableSet (name, s_value);
      return;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double OrdersClass::GVSerie_Get(int s_direction,int s_type){
   string name;
   if (s_type == _SERIE_BASE_LOT){
      if (s_direction == OP_BUY) name = "SERIE_SBL_BUY";
      if (s_direction == OP_SELL) name = "SERIE_SBL_SELL";
      return (GlobalVariableGet (name));
   }
   if (s_type == _SERIE_LAST_CLOSED_PROFIT){
      if (s_direction == OP_BUY) name = "SERIE_LCP_BUY";
      if (s_direction == OP_SELL) name = "SERIE_LCP_SELL";
      return (GlobalVariableGet (name));
   }
   if (s_type == _SERIE_GRID_STEP_NUMBER){
      if (s_direction == OP_BUY) name = "SERIE_GRID_STEP_NUMBER_BUY";
      if (s_direction == OP_SELL) name = "SERIE_GRID_STEP_NUMBER_SELL";
      return (GlobalVariableGet (name));
   }
   if (s_type == _SERIE_GRID_START_PRICE){
      if (s_direction == OP_BUY) name = "SERIE_GRID_START_PRICE_BUY";
      if (s_direction == OP_SELL) name = "SERIE_GRID_START_PRICE_SELL";
      return (GlobalVariableGet (name));
   }
   if (s_type == _SERIE_GRID_STEP_LENGTH){
      if (s_direction == OP_BUY) name = "SERIE_GRID_STEP_LENGTH_BUY";
      if (s_direction == OP_SELL) name = "SERIE_GRID_STEP_LENGTH_SELL";
      return (GlobalVariableGet (name));
   }
   return (-1);
}
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Serie_BE_New (int directionLocal, double newPriceLocal, double newLotLocal, ordersTotals &totals, ordersArray &positions[]){
   double numerator = 0, denominator = 0;
   double serieSL_Local = 0;
   if (directionLocal == OP_BUY){
      for (int index = 1; index <= totals.count; index++){
         if (positions[index].direction == OP_BUY){
            numerator += (positions[index].openPrice + commissionPips * Point) * positions[index].lot * tickValue / Point;
            denominator += positions[index].lot * tickValue / Point;
         }
      }
      numerator += (newPriceLocal  + commissionPips * Point) * newLotLocal * tickValue / Point;
   }
   
   if (directionLocal == OP_SELL){
      for (index = 1; index <= totals.count; index++){
         if (positions[index].direction == OP_SELL){
            numerator += (positions[index].openPrice - commissionPips * Point) * positions[index].lot * tickValue / Point;
            denominator += positions[index].lot * tickValue / Point;
         }
      }
      numerator += (newPriceLocal  - commissionPips * Point) * newLotLocal * tickValue / Point;
   }
   denominator += newLotLocal * tickValue / Point;
   if (denominator != 0) serieSL_Local = numerator / denominator;
   return (serieSL_Local);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double Serie_BE_Get (int directionLocal, double newPriceLocal, double newLotLocal, ordersTotals &totals, ordersArray &positions[]){
   double numerator = 0, denominator = 0;
   double serieSL_Local = 0;
   if (directionLocal == OP_BUY){
      for (int index = 1; index <= totals.count; index++){
         if (positions[index].direction == OP_BUY){
            numerator += (positions[index].openPrice + commissionPips * Point) * positions[index].lot * tickValue / Point;
            denominator += positions[index].lot * tickValue / Point;
         }
      }
      numerator += (newPriceLocal  + commissionPips * Point) * newLotLocal * tickValue / Point;
   }
   
   if (directionLocal == OP_SELL){
      for (index = 1; index <= totals.count; index++){
         if (positions[index].direction == OP_SELL){
            numerator += (positions[index].openPrice - commissionPips * Point) * positions[index].lot * tickValue / Point;
            denominator += positions[index].lot * tickValue / Point;
         }
      }
      numerator += (newPriceLocal  - commissionPips * Point) * newLotLocal * tickValue / Point;
   }
   denominator += newLotLocal * tickValue / Point;
   if (denominator != 0) serieSL_Local = numerator / denominator;
   return (serieSL_Local);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Serie_SL_Set (int directionLocal, double newSLPriceLocal, ordersTotals &totals, ordersArray &positions[]){
   bool modifyResult;
   if (directionLocal == OP_BUY){
      for (int index = 1; index <= totals.count; index++){
         if (positions[index].direction == OP_BUY){
            modifyResult = OrderModify (positions[index].ticket,positions[index].openPrice,newSLPriceLocal,positions[index].tp,0,Blue);
            }
         }
      }

   if (directionLocal == OP_SELL){
      for (index = 1; index <= totals.count; index++){
         if (positions[index].direction == OP_SELL){
            modifyResult = OrderModify (positions[index].ticket,positions[index].openPrice,newSLPriceLocal,positions[index].tp,0,Blue);
            }
         }
      }
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//double Serie_BE_Set (int directionLocal, ordersTotals &totals, ordersArray &positions[]){
//    double price_BE;
//    if (directionLocal == OP_BUY){
//        for (int index = 1; index <= totals.count; index++){
//            if (positions[index].direction == OP_BUY){
//            }
//        }
//    }
//        
//}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void costs_set (int spread_defaultLocal, double commission_default)
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
      spread_avg = spread_defaultLocal;
      }
      
   // Calculating commission   
   if (OrdersHistoryTotal () == 0) 
      commission = commission_default;
   else {
      for (int orderLocal = 0; orderLocal <= OrdersHistoryTotal ()-1; orderLocal++){
         if (OrderSelect (orderLocal,SELECT_BY_POS,MODE_HISTORY)){
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
   


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int deal_new_id (){
   string id_string = StringSubstr (TimeCurrent (),StringLen(TimeCurrent()) - 6,6);
   return (StrToInteger (id_string));
}
