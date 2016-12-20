//+------------------------------------------------------------------+
//|                                                    Q10NIK EXPERT |
//|                                   Copyright 2016, Zhinzhich Labs |
//+------------------------------------------------------------------+

class TrendlinesClass 
  {
private:
   int               tf[10];
   int               tf_lowest;

public:

   int               count;
   int               bo_numberMin;                          // If == 1 then the last trendline is BOed

   struct WavesStruct
     {
      double            price_start;
      double            price_end;
      double            range;
      int               time_start;
      int               time_end;
      int               duration;
      int               shift_start;
      int               shift_end;
     };

   struct VertexStruct
     {
      double            price;
      int               time;
      int               shift;
     };

   struct TrendlinesStruct
     {
      double            angle;
      int               direction;
      int               duration;                           // Time between wave [1] start and wave [3] end
      double            range;                              // Range between wave [1] start price and wave [3] end price
      double            amplitude_1;
      double            amplitude_2;
      double            retest_price;
      int               retest_time;
      bool              bo;

      WavesStruct       wave[4];                            // Waves are enumerated starting from the Earliest wave (Number [1]) in the trendline. [3] Waves overall.
      VertexStruct      vertex[5];                          // Vertex are enumerated starting from the Earliest vertex (Number [1]) in the trendline. [4] Vertexes overall.

     };

   struct CascadeStruct
     {
      int               count;
      double            range;
      TrendlinesStruct  trendline[10];
     };

   TrendlinesStruct  trendline[10];

   // Find trendline (with required amplitude) 
   double            Find(int direction,double amplitudeMin,int timeEarliest);

   // Find trendlines in a period
   int               FindInPeriod(int direction,int periodTimeStart,int periodTimeEnd);

   // Find trendlines cascade
   int               FindCascade(int direction,int timeStart,int timeEnd,double amplitudeMin);

   // Find amplitude of a trendline
   double            Amplitude(TrendlinesStruct &trendlineLocal);

   // Find retest prive
   double            RetestPrice(TrendlinesStruct &trendlineLocal);

   // Draw line
   void              DrawLine(string name_local,color color_line,int width,datetime time_open_local,double price_open_local,datetime time_close_local,double price_close_local);

   // Delete trendlines
   void              Delete(int direction);

   // Initialization
   void              Init(int timeframe_lowest);

   string            Get_date_string(int time_input);

   CascadeStruct     cascade[10];

   void              TrendlinesClass();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void TrendlinesClass::Init(int timeframe_lowest)
  {
   tf_lowest=timeframe_lowest;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void TrendlinesClass::TrendlinesClass()
  {
   if(tf[1]==0)
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
      tf_lowest=1;

     }
//  Print("Constructor is called each time");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//void TrendlinesClass::Draw (int direction, int timeEarlier, int timeLater)
//{
//   
//      
//   
//}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void TrendlinesClass::DrawLine(string name_local,color color_line,int width,datetime time_open_local,double price_open_local,datetime time_close_local,double price_close_local)
  {
   ObjectCreate(name_local,OBJ_TREND,0,time_open_local,price_open_local,time_close_local,price_close_local);
   ObjectSet(name_local,OBJPROP_STYLE,STYLE_DOT);
   ObjectSet(name_local,OBJPROP_WIDTH,1);
   ObjectSet(name_local,OBJPROP_RAY,false);
   ObjectSet(name_local,OBJPROP_COLOR,color_line);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int TrendlinesClass::FindInPeriod(int direction,int periodTimeStart,int periodTimeEnd)
  {

   int      periodShiftStart;
   int      periodShiftEnd;
   double   periodPriceStart;
   double   periodPriceEnd;

   int      waveTimeStart;
   int      waveTimeEnd;
   int      waveShiftStart;
   int      waveShiftEnd;
   double   wavePriceStart;
   double   wavePriceEnd;

   double   waveAngle;
   double   angle;
   double   angleMin;
   int      shiftStart;
   int      timeStart;

   int      vertex_Shift;
   int      vertex_Time;

   double   priceStart;
   int      swap;

   if(direction==OP_SELL)
     {
      // Finding DOWNWARD (SELL) trendlines
      if(periodTimeEnd<periodTimeStart)
        {           // Swapping time if wrong order of vertices
         swap              = periodTimeEnd;
         periodTimeEnd     = periodTimeStart;
         periodTimeStart   = swap;
        }

      periodShiftStart  = iBarShift (Symbol(), tf_lowest, periodTimeStart,false);
      periodShiftEnd    = iBarShift (Symbol(), tf_lowest, periodTimeEnd,false);

      waveShiftStart    = iHighest (Symbol(), tf_lowest, MODE_HIGH, periodShiftStart-periodShiftEnd+1, periodShiftEnd);
      waveShiftEnd      = iLowest (Symbol(), tf_lowest, MODE_LOW, periodShiftStart-periodShiftEnd+1, periodShiftEnd);

      wavePriceStart    = iHigh (Symbol(), tf_lowest, waveShiftStart);
      wavePriceEnd      = iLow (Symbol(), tf_lowest, waveShiftEnd);
      waveTimeEnd       = iTime (Symbol(), tf_lowest, waveShiftEnd);
      waveTimeStart     = iTime (Symbol(), tf_lowest, waveShiftStart);

      if(waveShiftStart<waveShiftEnd) return(0);  // This is a buy wave, exit

      if(waveShiftStart!=waveShiftEnd) waveAngle=(wavePriceStart-wavePriceEnd)/(waveTimeStart-waveTimeEnd);

      ObjectDelete("wave_SELL");
      ObjectCreate("wave_SELL",OBJ_TREND,0,waveTimeStart,wavePriceStart,waveTimeEnd,wavePriceEnd);
      ObjectSet("wave_SELL",OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet("wave_SELL",OBJPROP_WIDTH,1);
      ObjectSet("wave_SELL",OBJPROP_RAY,false);
      ObjectSet("wave_SELL",OBJPROP_COLOR,Red);

      if(waveAngle == 0) return (0);

      count       = 0;
      shiftStart  = waveShiftStart;
      priceStart  = wavePriceStart;
      timeStart   = waveTimeStart;

      while(count<=8)
        {
         for(int shift=shiftStart-1; shift>=waveShiftEnd; shift--)
           {
            angle=(iHigh(Symbol(),tf_lowest,shift)-priceStart)/(timeStart-iTime(Symbol(),tf_lowest,shift));
            if(shift==shiftStart-1)
              {
               angleMin=angle;
               vertex_Shift=shift;
              }
            if(MathAbs(angle)<MathAbs(angleMin))
              {
               angleMin=angle;
               vertex_Shift=shift;
              }
           }

         // If found more steep trendline - exit while loop
         if(MathAbs(angleMin)>MathAbs(waveAngle)) break;

         // Found trendline with less angle
         count++;

         trendline[count].wave[1].shift_start  = shiftStart;
         trendline[count].wave[1].price_start  = iHigh (Symbol(), tf_lowest, shiftStart);
         trendline[count].wave[1].time_start   = iTime (Symbol(), tf_lowest, shiftStart);

         trendline[count].wave[3].shift_start  = vertex_Shift;
         trendline[count].wave[3].price_start  = iHigh (Symbol(), tf_lowest, trendline[count].wave[3].shift_start);
         trendline[count].wave[3].time_start   = iTime (Symbol(), tf_lowest, trendline[count].wave[3].shift_start);

         trendline[count].direction=OP_SELL;

         shiftStart  = trendline[count].wave[3].shift_start;
         priceStart  = trendline[count].wave[3].price_start;
         timeStart   = trendline[count].wave[3].time_start;

         string name=StringConcatenate("trendlineSell_",count);

         ObjectDelete(name);
         ObjectCreate(name,OBJ_TREND,0,trendline[count].wave[1].time_start,trendline[count].wave[1].price_start,trendline[count].wave[3].time_start,trendline[count].wave[3].price_start);
         ObjectSet(name,OBJPROP_STYLE,STYLE_DOT);
         ObjectSet(name,OBJPROP_WIDTH,1);
         ObjectSet(name,OBJPROP_RAY,true);
         ObjectSet(name,OBJPROP_COLOR,Gray);

        }
     }

   return (count);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double TrendlinesClass::Amplitude(TrendlinesStruct &trendlineLocal)
  {

   double price_start;
   double price_end;
   double price_calc;
   double angle;
   double amplitude;

   if(trendlineLocal.direction==OP_BUY)
     {
      price_start   = trendlineLocal.vertex[1].price;
      price_end     = trendlineLocal.vertex[4].price;
      angle         = trendlineLocal.angle;
      amplitude     = 0;
      for(int shift=trendlineLocal.vertex[1].shift; shift>=trendlineLocal.vertex[4].shift; shift--)
        {
         price_calc=price_start+MathAbs(trendlineLocal.vertex[1].shift-shift)*angle;
         if(iHigh(Symbol(),tf_lowest,shift)-price_calc>amplitude) amplitude=iHigh(Symbol(),tf_lowest,shift)-price_calc;
        }
     }

   if(trendlineLocal.direction==OP_SELL)
     {
      price_start   = trendlineLocal.vertex[1].price;
      price_end     = trendlineLocal.vertex[4].price;
      angle         = trendlineLocal.angle;
      amplitude     = 0;
      for(shift=trendlineLocal.vertex[1].shift; shift>=trendlineLocal.vertex[4].shift; shift--)
        {
         price_calc=price_start-MathAbs(trendlineLocal.vertex[1].shift-shift)*angle;
         if(price_calc-iLow(Symbol(),tf_lowest,shift)>amplitude) amplitude=price_calc-iLow(Symbol(),tf_lowest,shift);
        }
     }

   return (amplitude);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string TrendlinesClass::Get_date_string(int time_input)
  {
   string string_result=StringConcatenate(TimeYear(time_input),".",TimeMonth(time_input),".",TimeDay(time_input),"   ",TimeHour(time_input),":",TimeMinute(time_input));
   if(time_input==0) string_result="0";
   return (string_result);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//int TrendlinesClass::FindLevels (int direction, int timeframe, int time_start, int time_end){
//	if (direction == OP_BUY){
//		int shift_start = iBarShift (Symbol (), timeframe, time_start, false);
//		int shift_end = iBarShift (Symbol (), timeframe, time_end, false);
//		
//		if (shift_end > shift_start){
//			int swap = shift_end;
//			shift_end = shift_start;
//			shift_start = swap;
//		}
//
//		int shift_lowest = iLowest (Symbol(), timeframe, shift_start - shift_end, shift_end);
//
//		// First seek right side
//		for (int shift = shift_lowest, shift >= shift_end; shift--){
//			if (iHigh (Symbol(),timeframe,shift) < iHigh(Symbol(),timeframe,shift-1)
//			&& iHigh (Symbol(),timeframe,shift) < iHigh(Symbol(),timeframe,shift+1)){
//				double corrector_price_right = iHigh (Symbol(),timeframe,shift);
//				break; 
//			}
//		}
//
//		// Second search left side
//		for (shift = shift_lowest, shift <= shift_start; shift++){
//			if (iHigh (Symbol(),timeframe,shift) < iHigh(Symbol(),timeframe,shift-1)
//			&& iHigh (Symbol(),timeframe,shift) < iHigh(Symbol(),timeframe,shift+1)){
//				double corrector_price_left = iHigh (Symbol(),timeframe,shift);
//				break;
//			}
//		}
//
//		// Choose the lowest corrector price
//		double corrector_price = corrector_price_right;
//		if (corrector_price_right > corrector_price_left) corrector_price = corrector_price_left;
//
//	}
//}
