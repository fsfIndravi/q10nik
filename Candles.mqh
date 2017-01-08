class CandlesClass {
private:
   int         timeframeLowest;
   int         tf[10];
      
public:
   struct driversStruct{
      int         timeframe;
      int         direction;
      double      price_High;
      double      price_Low;
      double      price_Open;
      double      price_Close;
      double      range;
      double      strength;
      double      strengthRatio;
      int         time;
      int         shift;
      double      touch2price;
      int         touch2time;
      int         touch2shift;
      double      touch2Strength;                  // Candle strength just after the 2 touch
      double      touch2Length;                    // Wave length after the 2 touch 
      double      touch2LengthRatio;               // Wave length Ratio to the opposite wave after the driver and before 2 touch. If >1 then there was a BO after the 2 touch
      };
   
   struct overlapStruct{
      driversStruct driver[20];
      int         tf;
      int         count;
      double      rangeMin;
      double      rangeTotal;
      double      priceHigh;
      double      priceLow;
   };
   
   struct correctorStruct{
      double      price;
      int         timeframe;
      double      length;              // Distance between corrector price and wave extremum
      double      lengthFinetuned;     
      bool        finetuned;
      int         shift;
      int         time;
   };

   // Find max candle range in a period
   double FindMaxRange (int x_timeframe, int x_timeEarlier, int x_timeLater);

   // Find candles mass
   int CandlesMass (int tfLocal, int extremumTime1, int extremumTime2);
   
   // Find Core Driver   
   double FindCoreWaveDriver (int timeframeLowest, int waveDirection, int waveTimeStart, int waveTimeEnd, double wavePriceHigh, double wavePriceLow, double coreDriverWaveRangeKoef);
   
   // Find corrector
   double FindCorrector (int timeframeLocal, int directionLocal, int vertex_time);

   // Pike hits a level where price changed its direction
   double FindPike (int timeframeLocal, int timeStart, int timeEnd, double priceLowest, double priceHighest, double pikeRangeRatio, double pikeLengthMin);

   // Find unnullivyed driver
   double Find (int f_timeframe, int f_direction, int f_timeEarlier, int f_timeLater, bool f_unnullifyed, double f_strengthMin);
   
   // Find driver relative to the wave length (regardless direction or timeframe)
   double FindDriver (int d_orderDirection, double d_lengthMin, int d_timeEarlier, int d_timeLater, double d_priceCheck);
   
   // Find overlap of drivers
   double FindOverlap (int overlapCount, double priceCheck, double rangeMin, int timeEarlier, int timeLater);
   
   // Find maximum overlap of driver in a priceRange
   double FindOverlapMax (double priceRangeHigh, double priceRangeLow, double rangeMin, int timeRangeEarlier, int timeRangeLater);
   
   // Find unnullivyed maximum strength of a candle during a period
   double FindMax (int x_timeframe, int x_direction, int x_timeEarlier, int x_timeLater, bool x_unnullifyed);
   
   // Lowest price
   double LowestPrice  (int l_timeStart, int l_timeEnd);
   
   // Highest price
   double HighestPrice (int h_timeStart, int h_timeEnd);
   
   // Check wave breakout
   bool Breakout (int b_directionBO, int b_waveOppositeTimeStart, int b_waveOppositeTimeEnd, int b_TimeframesUseFlag);
   
   // Count ratio (percent) of candles of a certain direction (buy or sell) in a period
   double RatioByDirection (int n_timeframe, int n_direction, int n_timeStart, int n_timeEnd);
   
   // Candle maximal timeframe for a certain period of time 
   int Timeframe_Max_Period (int x_timeStart, int x_timeEnd);
   
   // Candle maximal timframe since the TimeCurrent
   int Timeframe_Max_Current (int x_timeStart);
   
   // Average length by shift
   double AverageRange_Shift (int a_timeframe, int a_shiftEarlier, int a_shiftLater);
   
   // Average length by time
   double AverageRange_Time (int a_timeframe, int a_timeEarlier, int a_timeLater);
   
   // Class initialization
   void Init (int i_timeframeLowest);
   
   // TF functions
   int      TF_Number (int n_timeframe);
   int      TF_Lower (int l_timeframe);
   int      TF_Higher (int h_timeframe);
   int      TF_Max (int x_timeEarlier, int x_timeLater);
    
   // Calculate movement goal of a Time Period
   
   driversStruct driver;
   overlapStruct overlap;
   
   CandlesClass();
   
   int _BREAKOUT_TIMEFRAMES_ALL;
   int _BREAKOUT_TIMEFRAME_HIGHEST;
   int _BREAKOUT_TIMEFRAME_LOWEST;
      
   };
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CandlesClass::CandlesClass (void){
   if (tf[1] == 0){
      tf[1] = 1;
      tf[2] = 5;
      tf[3] = 15;
      tf[4] = 30;
      tf[5] = 60;
      tf[6] = 240;
      tf[7] = 1440;
      tf[8] = 10080;
      tf[9] = 43200;
   }
   if (timeframeLowest == 0) timeframeLowest = 1;
   if (_BREAKOUT_TIMEFRAMES_ALL == 0) _BREAKOUT_TIMEFRAMES_ALL = 1;
   if (_BREAKOUT_TIMEFRAME_HIGHEST == 0) _BREAKOUT_TIMEFRAME_HIGHEST = 2;
   if (_BREAKOUT_TIMEFRAME_LOWEST == 0) _BREAKOUT_TIMEFRAME_LOWEST = 3;
}




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

CandlesClass::Init (int i_timeframe){   
   timeframeLowest = i_timeframe;
}


//+------------------------------------------------------------------+
//| Finding nearest Driver                                           |
//+------------------------------------------------------------------+

double CandlesClass::Find (int f_timeframe, int f_direction, int f_timeEarlier, int f_timeLater, bool f_unnullifyed, double f_strengthMin){
   double priceCheck;
   double strengthLocal;
   int shiftEarlier  = iBarShift (Symbol(), f_timeframe, f_timeEarlier, false);
   int shiftLater    = iBarShift (Symbol(), f_timeframe, f_timeLater, false);
   // BUY DRIVERS
   if (f_direction == OP_BUY) {
      double priceLowest = iLow (Symbol(), f_timeframe, shiftLater);
      if (f_unnullifyed)   priceCheck = this.LowestPrice (f_timeLater,TimeCurrent());
         else priceCheck = iHigh (Symbol(), f_timeframe, shiftLater);
      for (int f_shift = shiftLater; f_shift <= shiftEarlier; f_shift++){
         if (priceLowest < iLow (Symbol(), f_timeframe, f_shift) || priceCheck < iLow (Symbol(), f_timeframe, f_shift)) continue;
         // If candle is Bullish, take the whole range of it
         if (iClose (Symbol(), f_timeframe, f_shift) - iOpen (Symbol(), f_timeframe, f_shift) > 0) strengthLocal = iHigh (Symbol(), f_timeframe, f_shift) - iLow (Symbol(), f_timeframe, f_shift);
         // If candle is Doji or Bearish take only the low part of it
         if (iClose (Symbol(), f_timeframe, f_shift) - iOpen (Symbol(), f_timeframe, f_shift) <= 0) strengthLocal = iClose (Symbol(), f_timeframe, f_shift) - iLow (Symbol(), f_timeframe, f_shift);
         if (strengthLocal >= f_strengthMin){
            driver.direction     = OP_BUY;
            driver.timeframe     = f_timeframe;
            driver.touch2price   = priceLowest;
            driver.price_Close    = iClose (Symbol(), f_timeframe, f_shift);
            driver.price_High     = iHigh (Symbol(), f_timeframe, f_shift);
            driver.price_Low      = iLow (Symbol(), f_timeframe, f_shift);
            driver.price_Open     = iOpen (Symbol(), f_timeframe, f_shift);
            driver.range         = iHigh (Symbol(), f_timeframe, f_shift) - iLow (Symbol(), f_timeframe, f_shift);
            driver.time          = iTime (Symbol(), f_timeframe, f_shift);
            driver.shift         = f_shift;
            driver.strength      = strengthLocal;
            if (driver.range != 0) driver.strengthRatio = driver.strength / driver.range;
            return (driver.strength);
         }         
         if (iLow (Symbol(), f_timeframe, f_shift) < priceLowest) priceLowest = iLow (Symbol(), f_timeframe, f_shift);
      }
   }
   
   // SELL DRIVERS
   if (f_direction == OP_SELL) {      
      double priceHighest = iHigh (Symbol(), f_timeframe, shiftLater);
      priceCheck = this.HighestPrice (f_timeLater,TimeCurrent());
      for (f_shift = shiftLater; f_shift <= shiftEarlier; f_shift++) {
         if (f_unnullifyed)   priceCheck = this.HighestPrice (f_timeLater,TimeCurrent());
                  else        priceCheck = iLow (Symbol(), f_timeframe, shiftLater);
         if (priceHighest > iHigh (Symbol(), f_timeframe, f_shift) || priceCheck > iHigh (Symbol(), f_timeframe, f_shift)) continue;
         if (iClose (Symbol(), f_timeframe, f_shift) - iOpen (Symbol(), f_timeframe, f_shift) < 0) strengthLocal = iHigh (Symbol(), f_timeframe, f_shift) - iLow (Symbol(), f_timeframe, f_shift);
         if (iClose (Symbol(), f_timeframe, f_shift) - iOpen (Symbol(), f_timeframe, f_shift) >= 0) strengthLocal = iHigh (Symbol(), f_timeframe, f_shift) - iClose (Symbol(), f_timeframe, f_shift);
         if (strengthLocal >= f_strengthMin) {
            driver.direction = OP_SELL;
            driver.timeframe = f_timeframe;            
            driver.touch2price = priceLowest;
            driver.price_Close = iClose (Symbol(), f_timeframe, f_shift);
            driver.price_High = iHigh (Symbol(), f_timeframe, f_shift);
            driver.price_Low = iLow (Symbol(), f_timeframe, f_shift);
            driver.price_Open = iOpen (Symbol(), f_timeframe, f_shift);
            driver.range = iHigh (Symbol(), f_timeframe, f_shift) - iLow (Symbol(), f_timeframe, f_shift);
            driver.time = iTime (Symbol(), f_timeframe, f_shift);
            driver.shift = f_shift;
            driver.strength = strengthLocal;
            if (driver.range != 0) driver.strengthRatio = driver.strength / driver.range;            
            return (driver.strength);
            }
         if (iHigh (Symbol(), f_timeframe, f_shift) > priceHighest) priceHighest = iHigh (Symbol(), f_timeframe, f_shift);         
         }
      }
   return (0);
   }
   



//+------------------------------------------------------------------+
//| Find maximum unnillifyed candle in a period                      |
//+------------------------------------------------------------------+

double CandlesClass::FindMax (int x_timeframe, int x_direction, int x_timeEarlier, int x_timeLater, bool x_unnullifyed){
   double x_priceCheck;
   double x_strengthMax = 0;
   int shiftEarlier = iBarShift (Symbol(), x_timeframe, x_timeEarlier, false);
   int shiftLater = iBarShift (Symbol(), x_timeframe, x_timeLater, false);
   if (x_direction == OP_BUY) {
      double price_Lowest = iLow (Symbol(), x_timeframe, shiftLater);
      if (x_unnullifyed)   x_priceCheck = LowestPrice (x_timeLater,TimeCurrent());
               else        x_priceCheck = iHigh (Symbol(), x_timeframe, shiftLater);
      for (int x_shift = shiftLater; x_shift <= shiftEarlier; x_shift++) {
         if (iLow (Symbol(), x_timeframe, x_shift) > x_priceCheck || iLow (Symbol(), x_timeframe, x_shift) > price_Lowest) continue;
         // If candle is Bullish, take the whole range of it
         if (iClose (Symbol(), x_timeframe, x_shift) - iOpen (Symbol(), x_timeframe, x_shift) > 0) {
            if (iHigh (Symbol(), x_timeframe, x_shift) - iLow (Symbol(), x_timeframe, x_shift) > x_strengthMax) x_strengthMax = iHigh (Symbol(), x_timeframe, x_shift) - iLow (Symbol(), x_timeframe, x_shift);
            }
         // If candle is Doji or Bearish take only the low part of it
         if (iClose (Symbol(), x_timeframe, x_shift) - iOpen (Symbol(), x_timeframe, x_shift) <= 0) {
            if (iClose (Symbol(), x_timeframe, x_shift) - iLow (Symbol(), x_timeframe, x_shift) > x_strengthMax) x_strengthMax = iClose (Symbol(), x_timeframe, x_shift) - iLow (Symbol(), x_timeframe, x_shift);
            }
         }
      if (iLow (Symbol(), x_timeframe, x_shift) < price_Lowest) price_Lowest = iLow (Symbol(), x_timeframe, x_shift);
      }
   
   if (x_direction == OP_SELL) {
      double price_Highest = iHigh (Symbol(), x_timeframe, shiftLater);
      if (x_unnullifyed)   x_priceCheck = HighestPrice (x_timeLater,TimeCurrent());
               else        x_priceCheck = iLow (Symbol(), x_timeframe, shiftLater);
      for (x_shift = shiftLater; x_shift <= shiftEarlier; x_shift++) {
         if (iHigh (Symbol(), x_timeframe, x_shift) < x_priceCheck || iHigh (Symbol(), x_timeframe, x_shift) < price_Highest) continue;
         // If candle is Bearish, take the whole range of it
         if (iClose (Symbol(), x_timeframe, x_shift) - iOpen (Symbol(), x_timeframe, x_shift) < 0) {
            if (iHigh (Symbol(), x_timeframe, x_shift) - iLow (Symbol(), x_timeframe, x_shift) > x_strengthMax) x_strengthMax = iHigh (Symbol(), x_timeframe, x_shift) - iLow (Symbol(), x_timeframe, x_shift);
            }
         // If candle is Doji or Bullish take only the high part of it
         if (iClose (Symbol(), x_timeframe, x_shift) - iOpen (Symbol(), x_timeframe, x_shift) >= 0) {
            if (iHigh (Symbol(), x_timeframe, x_shift) - iClose (Symbol(), x_timeframe, x_shift) > x_strengthMax) x_strengthMax = iHigh (Symbol(), x_timeframe, x_shift) - iClose (Symbol(), x_timeframe, x_shift);
            }
         }
      if (iHigh (Symbol(), x_timeframe, x_shift) > price_Highest) price_Highest = iHigh (Symbol(), x_timeframe, x_shift);
      }
      
   return (x_strengthMax);
   
   }




//+------------------------------------------------------------------+
//| Find maximum unnillifyed candle in a period                      |
//+------------------------------------------------------------------+

double CandlesClass::FindMaxRange (int x_timeframe, int x_timeEarlier, int x_timeLater){
   double x_rangeMax = 0;
   int shiftEarlier  = iBarShift (Symbol(), x_timeframe, x_timeEarlier, false);
   int shiftLater    = iBarShift (Symbol(), x_timeframe, x_timeLater, false);
   if (shiftLater > shiftEarlier){
       int swap = shiftLater;
       shiftEarlier = shiftLater;
       shiftLater = swap;
   }
   for (int x_shift = shiftLater; x_shift <= shiftEarlier; x_shift++) {
       if (iHigh (Symbol(), x_timeframe, x_shift) - iLow (Symbol(), x_timeframe, x_shift) > x_rangeMax) x_rangeMax = iHigh (Symbol(), x_timeframe, x_shift) - iLow (Symbol(), x_timeframe, x_shift);
  }
  return (x_rangeMax);
}




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int CandlesClass::Timeframe_Max_Period (int x_timeStart, int x_timeEnd)
   {
   for (int tf_num = 9; tf_num >= 1; tf_num--) {
      if (MathAbs (x_timeStart - x_timeEnd) / 60 / tf[tf_num] >= 2) return (tf[tf_num]);
      }
   return (0);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int CandlesClass::Timeframe_Max_Current (int x_timeStart)
   {
   for (int tf_num = 9; tf_num >= 1; tf_num--) {
      if ((iTime (Symbol(), tf[tf_num], 0) - x_timeStart) / 60 >= tf[tf_num]) return (tf[tf_num]);
      }
   return (0);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool CandlesClass::Breakout (int b_directionBO,int b_waveOppositeTimeStart,int b_waveOppositeTimeEnd,int b_TimeframesUseFlag)
   {
   int      tf_highest;
   double   price_Highest;
   double   price_Lowest;
   int      shiftStart;
   int      shift_Lowest;
   int      time_Lowest;
   int      time_Highest;
   double   driverOppositeStrength;
   double   driverStrength;
   if (b_directionBO == OP_BUY) {
      // Check only the highest timeframe BO
      if (b_TimeframesUseFlag == _BREAKOUT_TIMEFRAME_HIGHEST) {
         tf_highest     = Timeframe_Max_Current (b_waveOppositeTimeEnd);
         shift_Lowest   = iBarShift (Symbol(), tf_highest, b_waveOppositeTimeEnd, false);
         time_Lowest    = iTime (Symbol(), tf_highest, shift_Lowest);
         }
      // Check all inclusive timeframes BO
      if (b_TimeframesUseFlag == _BREAKOUT_TIMEFRAMES_ALL) {
         tf_highest     = Timeframe_Max_Current (b_waveOppositeTimeStart);
         shift_Lowest   = iLowest (Symbol(), tf_highest, MODE_LOW, iBarShift (Symbol(), tf_highest, b_waveOppositeTimeStart, false),0);
         time_Lowest    = iTime (Symbol(), tf_highest, shift_Lowest);
         }
      }
   return (false);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CandlesClass::LowestPrice(int l_timeEarlier,int l_timeLater)
   {
   
   int timeframeMax     = Timeframe_Max_Period (l_timeEarlier, l_timeLater);
   int shiftEarlier     = iBarShift (Symbol(), timeframeMax, l_timeEarlier, false);
   int shiftLater       = iBarShift (Symbol(), timeframeMax, l_timeLater, false);
   double lowestPrice   = iLow (Symbol(), timeframeMax, iLowest (Symbol(), timeframeMax, MODE_LOW, shiftEarlier - shiftLater, shiftLater));
   
   return (lowestPrice);
   
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CandlesClass::HighestPrice(int l_timeEarlier,int l_timeLater)
   {
   
   int timeframeMax     = Timeframe_Max_Period (l_timeEarlier, l_timeLater);
   int shiftEarlier     = iBarShift (Symbol(), timeframeMax, l_timeEarlier, false);
   int shiftLater       = iBarShift (Symbol(), timeframeMax, l_timeLater, false);
   double highestPrice  = iHigh (Symbol(), timeframeMax, iHighest (Symbol(), timeframeMax, MODE_HIGH, shiftEarlier - shiftLater, shiftLater));
   
   return (highestPrice);
   
   }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CandlesClass::AverageRange_Shift (int a_timeframe, int a_shiftEarlier, int a_shiftLater)
   {
   double lengthTotal = 0;
   double lengthAvg = 0;
   Print ("a_timeframe="+a_timeframe+"   a_shiftEarlier="+a_shiftEarlier+"   a_shiftLater="+a_shiftLater,Red);
   for (int shiftLocal = a_shiftLater; shiftLocal <= a_shiftEarlier; shiftLocal++){
      lengthTotal += iHigh (Symbol(), a_timeframe, shiftLocal) - iLow (Symbol(), a_timeframe, shiftLocal);
      }
   if (a_shiftEarlier-a_shiftLater > 0) lengthAvg = lengthTotal / (a_shiftEarlier-a_shiftLater);
   return (lengthAvg);
   }



//+------------------------------------------------------------------+
//| Find core Driver to Enter
//+------------------------------------------------------------------+

double CandlesClass::FindDriver (int d_orderDirection, double d_lengthMin, int d_timeEarlier, int d_timeLater, double d_priceCheck){
   /*
   'd_direction mode' - OP_BUY - Only BUY Drivers, OP_SELL - Only SELL Drivers, OP_ALL - Both directions
   - driver must start from the bottom third of a buy wave
   - driver must be more that 17% from the wave length
   - 
   */
   int shiftEarlier;
   int shiftLater;
   double priceHighest;
   double priceLowest;
   
   if (d_orderDirection == OP_BUY){
      for (int t = 9; t >= 1; t--){
         shiftEarlier = iBarShift (Symbol(), tf[t], d_timeEarlier, false);
         shiftLater = iBarShift (Symbol(), tf[t], d_timeLater, false);
         for (int shift_d = shiftLater; shift_d <= shiftEarlier; shift_d++){
            if (iHigh (Symbol(), tf[t], shift_d) - iLow (Symbol(), tf[t], shift_d) >= d_lengthMin
               && iHigh (Symbol(), tf[t], shift_d) - iLow (Symbol(), tf[t], shift_d) > iHigh (Symbol(), tf[t], shift_d+1) - iLow (Symbol(), tf[t], shift_d+1)      /// Is longer that the previous candle
               && iHigh (Symbol(), tf[t], shift_d) - iLow (Symbol(), tf[t], shift_d) > iHigh (Symbol(), tf[t], shift_d-1) - iLow (Symbol(), tf[t], shift_d-1)      /// Is longer that the next candle
               ){
               // The driver must be with good bounce - that points to the reversal level
               if (iClose (Symbol(), tf[t], shift_d) >= iOpen (Symbol(), tf[t], shift_d)) driver.direction = OP_BUY;
               if (iClose (Symbol(), tf[t], shift_d) < iOpen (Symbol(), tf[t], shift_d)) driver.direction = OP_SELL;
               driver.price_Close = iClose (Symbol(), tf[t], shift_d);
               driver.price_High = iHigh (Symbol(), tf[t], shift_d);
               driver.price_Low = iLow (Symbol(), tf[t], shift_d);
               driver.price_Open = iOpen (Symbol(), tf[t], shift_d);
               driver.range = iHigh (Symbol(), tf[t], shift_d) - iLow (Symbol(), tf[t], shift_d);
               driver.timeframe = tf[t];
            }
         }
      }
   }
}




//+------------------------------------------------------------------+
//| Finds the first occurred ovelap from the lower timeframe
//+------------------------------------------------------------------+

double CandlesClass::FindOverlap (int overlapCount, double priceCheck, double rangeMin, int timeEarlier, int timeLater){
   int shiftEarlier;
   int shiftLater;
   int count = 0;
   overlap.rangeTotal = 0;
   overlap.priceHigh = 0;
   overlap.priceLow = 0;
   // 1. Initialize drivers array
   for (int t = TF_Number (timeframeLowest); t <= 9; t++){
      shiftEarlier = iBarShift (Symbol(), tf[t], timeEarlier, false);
      shiftLater = iBarShift (Symbol(), tf[t], timeLater, false);
      for (int shift = shiftLater; shift <= shiftEarlier; shift++){
         if (iHigh (Symbol(), tf[t], shift) - iLow (Symbol(), tf[t], shift) >= rangeMin){
            count++;
            overlap.tf = tf[t];
            overlap.driver[count].price_High = iHigh (Symbol(), tf[t], shift);
            overlap.driver[count].price_Low = iLow (Symbol(), tf[t], shift);
            overlap.rangeTotal += iHigh (Symbol(), tf[t], shift) - iLow (Symbol(), tf[t], shift);
         }
      }
   }
}




//+------------------------------------------------------------------+
//| TF functions
//+------------------------------------------------------------------+

int CandlesClass::TF_Lower(int l_timeframe){
   for (int t = 2; t <= 9; t++){
      if (tf[t] == l_timeframe) return (tf[t-1]);
   }
   return (0);
}

int CandlesClass::TF_Higher(int h_timeframe){
   for (int t = 8; t >= 1; t--){
      if (tf[t] == h_timeframe) return (tf[t+1]);
   }
   return (0);
}

int CandlesClass::TF_Number (int n_timeframe){
   for (int t = 9; t >= 1; t--){
      if (tf[t] == n_timeframe) return (t);
   }
   return (0);
}

int CandlesClass::TF_Max(int x_timeEarlier,int x_timeLater){
   for (int t = 9; t >= 1; t--){
      if ((x_timeLater - x_timeEarlier)/60/tf[t]>=2) return (tf[t]);
   }
   return (0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CandlesClass::FindCoreWaveDriver (int timeframeLowest, int waveDirection, int waveTimeStart, int waveTimeEnd, double wavePriceHigh, double wavePriceLow, double coreDriverWaveRangeKoef){
   int shiftEarlier;
   int shiftLater;
   double rangeLocal;
   double rangeMax = 0;
   int count = 0;
   
//   if (waveDirection == OP_BUY){
//   // 1. Initialize drivers array
//   for (int t = TF_Number (timeframeLowest); t <= 9; t++){
//      shiftEarlier = iBarShift (Symbol(), tf[t], waveTimeStart, false);
//      shiftLater = iBarShift (Symbol(), tf[t], waveTimeEnd, false);
//      for (int shift = shiftLater; shift <= shiftEarlier; shift++){
//         rangeLocal = iHigh (Symbol(), tf[t], shift) - iLow (Symbol(), tf[t], shift);
//         //if (rangeLocal >= coreDriverRangeKoef * (wavePriceHigh - wavePriceLow)
//         && rangeLocal > rangeMax
//         //&& (iHigh (Symbol(), tf[t], shift) + iLow (Symbol(), tf[t])) / 2 <= (wavePriceHigh + wavePriceLow) / 2      // Center of the driver must be before 50% of the wave
//         && wavePriceHigh - iHigh (Symbol(), tf[t], shift) >= rangeLocal)                                          // 
//         
//         {
//            
//         }
//      if (rangeLocal > rangeMax) rangeMax = rangeLocal;
//      }
//   }
//}
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CandlesClass::FindCorrector (int timeframeLocal, int directionLocal, int vertex_time){
    double corrector_price;
    int vertex_shift = iBarShift (Symbol(),timeframeLocal,vertex_time,false);
    //  Finding correctors BUY
    if (directionLocal == OP_BUY){
        double vertex_low = iLow (Symbol(),timeframeLocal,vertex_shift);
        // Finding the first corrector to the right 
        int shiftRight = vertex_shift;
        bool foundRight = false;
        while (shiftRight>0){
            if (iHigh (Symbol(), timeframeLocal, shiftRight) < iHigh (Symbol(), timeframeLocal, shiftRight-1)
            && iHigh (Symbol(), timeframeLocal, shiftRight) < iHigh (Symbol(), timeframeLocal, shiftRight+1)) {foundRight=true;break;}
            shiftRight--; 
        }
        // Finding the first corrector to the left
        int shiftLeft = vertex_shift+1;
        bool foundLeft = false;
        while (shiftLeft<vertex_shift+12){
            if (iHigh (Symbol(), timeframeLocal, shiftLeft) < iHigh (Symbol(), timeframeLocal, shiftLeft-1)
            && iHigh (Symbol(), timeframeLocal, shiftLeft) < iHigh (Symbol(), timeframeLocal, shiftLeft+1)) {foundLeft=true;break;}
            shiftLeft++;
        }
        // Finding the lowest corrector between the two
        if (foundRight && foundLeft){
            if (iHigh (Symbol(), timeframeLocal, shiftRight) <= iHigh (Symbol(), timeframeLocal, shiftLeft)) return (iHigh (Symbol(), timeframeLocal, shiftRight));
                else return (iHigh (Symbol(), timeframeLocal, shiftLeft));
        }
        if (!foundRight && foundLeft) return (iHigh (Symbol(), timeframeLocal, shiftLeft));
        if (foundRight && !foundLeft) return (iHigh (Symbol(), timeframeLocal, shiftRight));

    }

    if (directionLocal == OP_SELL){
        double vertex_high = iHigh (Symbol(),timeframeLocal,vertex_shift);
        // Finding the first corrector to the right 
        shiftRight = vertex_shift;
        foundRight = false;
        while (shiftRight>0){
            if (iLow (Symbol(), timeframeLocal, shiftRight) > iLow (Symbol(), timeframeLocal, shiftRight-1)
            && iLow (Symbol(), timeframeLocal, shiftRight) > iLow (Symbol(), timeframeLocal, shiftRight+1)) {foundRight=true;break;}
            shiftRight--; 
        }
        // Finding the first corrector to the left
        shiftLeft = vertex_shift+1;
        foundLeft = false;
        while (shiftLeft<vertex_shift+12){
            if (iLow (Symbol(), timeframeLocal, shiftLeft) > iLow (Symbol(), timeframeLocal, shiftLeft-1)
            && iLow (Symbol(), timeframeLocal, shiftLeft) > iLow (Symbol(), timeframeLocal, shiftLeft+1)) {foundLeft=true;break;}
            shiftLeft++;
        }
        // Finding the lowest corrector between the two
        if (foundRight && foundLeft){
            if (iLow (Symbol(), timeframeLocal, shiftRight) >= iLow (Symbol(), timeframeLocal, shiftLeft)) return (iLow (Symbol(), timeframeLocal, shiftRight));
                else return (iLow (Symbol(), timeframeLocal, shiftLeft));
        }
        if (!foundRight && foundLeft) return (iLow (Symbol(), timeframeLocal, shiftLeft));
        if (foundRight && !foundLeft) return (iLow (Symbol(), timeframeLocal, shiftRight));
    }


}
   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double CandlesClass::FindPike (int timeframeLocal, int timeStart, int timeEnd, double priceLowest, double priceHighest, double pikeRangeRatio, double pikeLengthMin){
    int shiftStart = iBarShift (Symbol(),timeframeLocal,timeStart,false);
    int shiftEnd = iBarShift (Symbol(),timeframeLocal,timeStart,false);
    double priceHigh;
    double priceClose;
    double priceOpen;
    double priceLow;

    if (shiftStart <= shiftEnd){
        int swap = shiftStart;
        shiftStart = shiftEnd;
        shiftEnd = swap;
    }
    for (int shiftLocal = shiftEnd; shiftLocal <= shiftStart; shiftLocal++){
        priceHigh = iHigh(Symbol(),timeframeLocal,shiftLocal);
        priceClose = iClose(Symbol(),timeframeLocal,shiftLocal);
        priceOpen = iOpen(Symbol(),timeframeLocal,shiftLocal);
        priceLow = iLow(Symbol(),timeframeLocal,shiftLocal);
        if (priceHigh - priceLow > 0){
            // Finding 1-candle HIGH pikes
            if (priceHigh - priceClose >= pikeLengthMin
            && priceHigh - priceOpen >= pikeLengthMin 
            && (priceHigh - priceClose) / (priceHigh - priceLow) >= pikeRangeRatio
            && (priceHigh - priceOpen) / (priceHigh - priceLow) >= pikeRangeRatio
            && priceHigh <= priceHighest
            && priceHigh >= priceLowest)
                return (priceHigh); 
            // Finding 1-candle LOW pikes
            if (priceClose - priceLow >= pikeLengthMin
            && priceOpen - priceLow >= pikeLengthMin 
            && (priceClose - priceLow) / (priceHigh - priceLow) >= pikeRangeRatio
            && (priceOpen - priceLow) / (priceHigh - priceLow) >= pikeRangeRatio
            && priceLow <= priceHighest
            && priceLow >= priceLowest)
                return (priceLow); 
        }
    }
}




