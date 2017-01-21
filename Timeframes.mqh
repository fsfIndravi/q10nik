

class TimeframesClass
  {
private:
   
   int      timeframeFactorMin;
   
public:

   int      Lower (int l_timeframe);  // Get lower timeframe using timeframe factor
   int      Higher (int h_timeframe);  // Get higher timeframe using timeframe factor
   int      TF_Number (int n_timeframe); // Get timeframe number
   int      Highest (int timeStart, int timeEnd, int fullCandlesCountMin); // Get the hiest timeframe with full candle closed in a period
   int      tf[10];
   
   void     Init (int i_timeframeFactorMin);
   
   TimeframesClass ();

  };


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

TimeframesClass::TimeframesClass ()
   {   
   if (tf[1] == 0)
      {
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
   if (timeframeFactorMin == 0) timeframeFactorMin = 4;   
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

TimeframesClass::Init (int i_timeframeFactorMin)
   {
   timeframeFactorMin = i_timeframeFactorMin;
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int TimeframesClass::Lower (int l_timeframe)
   {
   for (int l_pos = TF_Number (l_timeframe); l_pos >= 1; l_pos--)
      {
      if (tf[l_pos] * timeframeFactorMin <= l_timeframe) return (tf[l_pos]);
      }   
   return (0);   
   }
   
   
   
   
   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int TimeframesClass::Higher (int h_timeframe)
   {
   for (int h_pos = TF_Number (h_timeframe); h_pos <= 9; h_pos++)
      {
      if (tf[h_pos] >= timeframeFactorMin * h_timeframe) return (tf[h_pos]);
      }   
   return (0);   
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int TimeframesClass::TF_Number (int n_timeframe)
   {
   for (int n_pos = 1; n_pos <= 9; n_pos++){
      if (tf[n_pos] == n_timeframe) return (n_pos);
      }
   return (0);
   }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int TimeframesClass::Highest (int timeStart, int timeEnd, int fullCandlesCountMin){
   int shiftStart;
   int shiftEnd;
   for (int timeframe = tf [9]; timeframe >= tf [1]; timeframe--){
      shiftStart = iBarShift (Symbol (), timeframe, timeStart, false);
      shiftEnd = iBarShift (Symbol (), timeframe, timeEnd, false);
      if (MathAbs (shiftStart - shiftEnd) >= fullCandlesCountMin) return (timeframe);
   }
}
