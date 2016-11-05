//+------------------------------------------------------------------+
//|                                                    Q10NIK EXPERT |
//|                                   Copyright 2016, Zhinzhich Labs |
//+------------------------------------------------------------------+

class WavesClass
  {
private:
   double            PeriodMin();
   double            LengthMin();
   double            Costs();

   double            dealCostsMax;
   double            dealRiskCostsKoef;
   int               seekShiftMax;
   int               timeframeWorking;
   int               dealDurationMax;
   bool              visualizeWaves;
   int               tf[10];

   int               compressedShift;
   int               compressedTime;
   int               compressedTimeframe;

   void              Visualize_Draw(string v_name,int v_timeStart,int v_timeEmd,double v_priceStart,double v_priceEnd,color v_color,int v_type);
   void              Visualize_Clear(string c_name);
   string            Get_date_string(int time_input);
   int               TF_Number(int n_timeframe);
   int               TF_Lower(int l_timeframe);
   int               TF_Higher(int h_timeframe);
   int               TF_Max(int x_timeEarlier,int x_timeLater);
   void              TF_Init();

   // DEFAULT PARAMETERS

#define _decompressionTimeframeRatioMax 40
#define _timeframeWorking 5
#define _seekShiftMax 200
#define _visualizeWaves 0
#define _deal_costs_max 0.05
#define _deal_risk_costs_koef 5.0
#define _deal_risk_percent 3.0
#define _spread_default 20
#define _commission_default 10
#define _spread_max_avg_koef 2.0
#define _average_period 15
#define _dealDurationMax 1440
#define _cascadeImpulsesMax 9
#define LOWERLOW 1
#define HIGHERHIGH 2

public:

   struct waveStruct
     {
      int               timeStart;
      int               timeEnd;
      double            price_Start;
      double            price_End;
      double            price_033;
      double            price_050;
      double            price_066;
      double            price_130;              // BO of the Wave for 130%
      double            price_150;              // BO of the Wave for 150%
      double            price_200;              // BO of the Wave for 200%
      double            price_goal_3w;          // 3-Wave Price Goal
      double            price_goal_13;          // 130% from the Wave brakeout
      double            price_goal_15;          // 150% from the Wave brakeout
      double            price_goal_20;          // 200% from the Wave brakeout
      double            length;
      int               duration;
      int               direction;
      int               tf_End;
      int               tfMax;
      int		tf_Start;
      int               shift_Start;
      int		shift_End;
};

   struct cascadeStruct
     {
      int               direction;              // OP_BUY / OP_SELL
      int               depth;                  // Number of impulses in the Cascade
      double            price_Start;
      double            price_End;
      double            price_033;
      double            price_050;
      double            price_066;
      double            price_130;              // BO of the Cascade price for 130%
      double            price_150;              // BO of the Cascade price for 150%
      double            price_200;              // BO of the Cascade price for 200%
      double            price_goal_3w;          // 3-Wave Price Goal of the Cascade
      double            price_goal_13;          // 130% from the brokeout retrace Cascade Goal
      double            price_goal_15;          // 150% from the brokeout retrace Cascade Goal
      double            price_goal_20;          // 200% from the brokeout retrace Cascade Goal
      double            price_RetraceMax;
      int               time_Start;
      int               time_End;
      int               time_Retrace;
      double            retraceRatioMax;
      double            retraceRange;
      waveStruct        impulse[_cascadeImpulsesMax+1];
     };

   // Methods
   int               FindCascade(int c_direction,int c_minorWaveLengthMin,int c_majorWaveDurationMax,int c_drawWaves);
   int               FindAll(int s_direction,double r_lengthMin);
   bool              FindByLength(int f_direction,double r_lengthMin,int r_timeEndMax);
   bool              FindByPeriod(double periodMin);
   bool              FindByTime(int timeEnd);
   double            RetraceRatioMax(int r_direction,int r_timeStart,int r_timeEnd,double r_priceStart,double r_priceEnd);
   void              Init(int timeframeWorking,int seekShiftMax,double dealCostsMax,int dealDurationMax,int visualizeWaves);
   void              FindMajor(int m_direction,int m_minorTimeStart); // Find major wave to the seeked one
   void              FindOpposite(int o_direction,int o_impulseTimeStart,int o_impulseTimeEnd,double o_impulsePriceEnd);
   bool              waveFind(int param);
   void              Compress(int compressRatio,int extremumType,int timeframeSource,int shiftSource);
   int               Decompress(int extremumType,int timeframeSource,int shiftSource,int timeframeTarget);

   double            CandleAverageBody();
   double            DirectionRatio();
   bool              FindByLength_Compressed(int f_direction,double r_lengthMin,int r_timeEndMax);

   // Initialize data structures and subclasses

   waveStruct        impulse;
   waveStruct        major;
   waveStruct        majorRetrace;
   waveStruct        opposite;
   waveStruct        retrace;

   cascadeStruct     cascade;

   // Main class constructor

                     WavesClass();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

WavesClass::WavesClass(void)
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
     }

   if(timeframeWorking==0) timeframeWorking=_timeframeWorking;
   if(seekShiftMax == 0) seekShiftMax = _seekShiftMax;
   if(dealCostsMax == 0) dealCostsMax = _deal_costs_max;
   if(dealRiskCostsKoef==0) dealRiskCostsKoef=_deal_risk_costs_koef;
   if(dealDurationMax==0) dealDurationMax=_dealDurationMax;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

WavesClass::Init(int init_timeframeWorking,int init_seekShiftMax,double init_DealCostsMax,int init_dealDurationMax,int init_visualizeWaves)
  {

   timeframeWorking=init_timeframeWorking;
   seekShiftMax = init_seekShiftMax;
   dealCostsMax = init_DealCostsMax;
   visualizeWaves=init_visualizeWaves;

  }
//+------------------------------------------------------------------+
//| Retrace Ratio Max                                                |
//| -- Calculates the maximum retrace during the wave (e.g. 0.32)    |
//| -- The lower the maximum retrace - the stronger the wave         |
//+------------------------------------------------------------------+

double WavesClass::RetraceRatioMax(int r_direction,int r_timeEarlier,int r_timeLater,double r_priceEarlier,double r_priceLater)
  {

   double   priceHighest;
   double   priceLowest;
   bool     checkFlag;
   int      shiftHighest;
   int      shiftLowest;
   double   retraceRatioMax;

   int shiftEarlier=iBarShift(Symbol(),timeframeWorking,r_timeEarlier,false);
   int shiftLater=iBarShift(Symbol(),timeframeWorking,r_timeLater,false);

   if(r_direction==OP_BUY)
     {
      priceHighest   = 0;
      priceLowest    = 0;
      checkFlag=false; // Flag used to mark a start for calculating maximum retrace
      shiftHighest=0;
      Print("OP_BUY="+OP_BUY+"    r_direction="+r_direction+"   r_timeEarlier="+Get_date_string(r_timeEarlier)+"   r_timeLater="+Get_date_string(r_timeLater)+"   r_priceEarlier="+r_priceEarlier+"   r_priceLater="+r_priceLater);
      for(int shiftLocal=shiftEarlier; shiftLocal>=shiftLater; shiftLocal--)
        {
         if(iHigh(Symbol(),timeframeWorking,shiftLocal)>=r_priceEarlier+0.66 *(r_priceLater-r_priceEarlier)) checkFlag=true;
         if(!checkFlag) continue;
         if(iHigh(Symbol(),timeframeWorking,shiftLocal)>priceHighest)
           {
            shiftHighest = shiftLocal;
            priceHighest = iHigh (Symbol(), timeframeWorking, shiftLocal);
            priceLowest  = iHigh (Symbol(), timeframeWorking, shiftLocal);
           }
         if(r_priceLater-r_priceEarlier!=0)
           {
            if(MathAbs((priceHighest-priceLowest)/(r_priceLater-r_priceEarlier))>retraceRatioMax) retraceRatioMax=MathAbs((priceHighest-priceLowest)/(r_priceLater-r_priceEarlier));
           }
        }
      return (retraceRatioMax);
     }

   if(r_direction==OP_SELL)
     {
      priceHighest   = 0;
      priceLowest    = 0;
      checkFlag=false; // Flag used to mark a start for calculating maximum retrace
      shiftHighest   =0;
      for(shiftLocal=shiftEarlier; shiftLocal>=shiftLater; shiftLocal--)
        {
         if(iLow(Symbol(),timeframeWorking,shiftLocal)<=r_priceEarlier-0.66*MathAbs(r_priceLater-r_priceEarlier)) checkFlag=true;
         if(!checkFlag) continue;
         if(iLow(Symbol(),timeframeWorking,shiftLocal)<priceLowest || priceLowest==0)
           {
            shiftLowest = shiftLocal;
            priceLowest = iLow (Symbol(), timeframeWorking, shiftLocal);
            priceHighest= iLow(Symbol(),timeframeWorking,shiftLocal);
           }
         if(r_priceLater-r_priceEarlier!=0)
           {
            if(MathAbs((priceHighest-priceLowest)/(r_priceLater-r_priceEarlier))>retraceRatioMax) retraceRatioMax=MathAbs((priceHighest-priceLowest)/(r_priceLater-r_priceEarlier));
           }
        }
      return (retraceRatioMax);
     }

   return (0);
  }
//+------------------------------------------------------------------+
//| Find wave by length                       
//| -- seeking for a wave till its goal length
//+------------------------------------------------------------------+

bool WavesClass::FindByLength(int f_direction,double r_lengthMin,int r_timeEndMax)
  {

   int      shiftLocal     = iBarShift (Symbol(), timeframeWorking, r_timeEndMax, false);
   double   priceMax       = iHigh (Symbol (), timeframeWorking, shiftLocal);
   double   priceMin       = iLow (Symbol (), timeframeWorking, shiftLocal);
   int      priceMaxTime   = iTime (Symbol (), timeframeWorking, shiftLocal);
   int      priceMinTime   = iTime (Symbol (), timeframeWorking, shiftLocal);

   if(f_direction==OP_BUY)
     {
      while(shiftLocal++<seekShiftMax)
        {
         if(iHigh(Symbol(),timeframeWorking,shiftLocal)>priceMax)
           {
            priceMax       = iHigh (Symbol(), timeframeWorking, shiftLocal);
            priceMin       = iHigh (Symbol(), timeframeWorking, shiftLocal);
            priceMaxTime   = iTime (Symbol(), timeframeWorking, shiftLocal);
            priceMinTime   = iTime (Symbol(), timeframeWorking, shiftLocal);
           }
         if(iLow(Symbol(),timeframeWorking,shiftLocal)<priceMin)
           {
            priceMin=iLow(Symbol(),timeframeWorking,shiftLocal);
            priceMinTime=iTime(Symbol(),timeframeWorking,shiftLocal);
           }
         if(priceMax-priceMin>=r_lengthMin)
           {
            // Seeking for the nearest opposite wave no less than 33% of wave length
            // so that the wave was obvious
            double   shift2_priceMax = priceMin;
            double   shift2_priceMin = priceMin;
            int      shift2_priceMaxTime = priceMinTime;
            int      shift2_priceMinTime = priceMinTime;
            for(int shift2=shiftLocal+1; shift2<seekShiftMax; shift2++)
              {

               if(iLow(Symbol(),timeframeWorking,shift2)<shift2_priceMin)
                 {
                  shift2_priceMin = iLow (Symbol(), timeframeWorking, shift2);
                  shift2_priceMax = iLow (Symbol(), timeframeWorking, shift2);
                  shift2_priceMaxTime = iTime (Symbol(), timeframeWorking, shift2);
                  shift2_priceMinTime = iTime (Symbol(), timeframeWorking, shift2);
                 }

               if(iHigh(Symbol(),timeframeWorking,shift2)>shift2_priceMax)
                 {
                  shift2_priceMax=iHigh(Symbol(),timeframeWorking,shift2);
                  shift2_priceMaxTime=iTime(Symbol(),timeframeWorking,shift2);
                 }

               if(shift2_priceMax-shift2_priceMin>=0.33 *(priceMax-shift2_priceMin))
                 {
                  impulse.timeStart=shift2_priceMinTime;
                  impulse.timeEnd=priceMaxTime;
                  impulse.price_Start=shift2_priceMin;
                  impulse.price_End=priceMax;
                  impulse.length=impulse.price_End-impulse.price_Start;
                  impulse.duration=impulse.timeEnd-impulse.timeStart;
                  impulse.direction=OP_BUY;
                  return (true);

                 }

              }


           }
        }

     }

   if(f_direction==OP_SELL)
     {
      while(shiftLocal++<seekShiftMax)
        {
         if(iLow(Symbol(),timeframeWorking,shiftLocal)<priceMin)
           {
            priceMax = iLow (Symbol(), timeframeWorking, shiftLocal);
            priceMin = iLow (Symbol(), timeframeWorking, shiftLocal);
            priceMaxTime = iTime (Symbol(), timeframeWorking, shiftLocal);
            priceMinTime = iTime (Symbol(), timeframeWorking, shiftLocal);
           }

         if(iHigh(Symbol(),timeframeWorking,shiftLocal)>priceMax)
           {
            priceMax=iHigh(Symbol(),timeframeWorking,shiftLocal);
            priceMaxTime=iTime(Symbol(),timeframeWorking,shiftLocal);
           }

         if(priceMax-priceMin>=r_lengthMin)
           {

            // Seeking for the nearest opposite wave no less than 33% of wave length
            // so that the wave was obvious

            shift2_priceMax = priceMin;
            shift2_priceMin = priceMin;

            shift2_priceMaxTime = priceMinTime;
            shift2_priceMinTime = priceMinTime;

            for(shift2=shiftLocal+1; shift2<seekShiftMax; shift2++)
              {
               if(iHigh(Symbol(),timeframeWorking,shift2)>shift2_priceMax)
                 {
                  shift2_priceMin = iHigh (Symbol(), timeframeWorking, shift2);
                  shift2_priceMax = iHigh (Symbol(), timeframeWorking, shift2);
                  shift2_priceMaxTime = iTime (Symbol(), timeframeWorking, shift2);
                  shift2_priceMinTime = iTime (Symbol(), timeframeWorking, shift2);
                 }
               if(iLow(Symbol(),timeframeWorking,shift2)<shift2_priceMin)
                 {
                  shift2_priceMin=iLow(Symbol(),timeframeWorking,shift2);
                  shift2_priceMinTime=iTime(Symbol(),timeframeWorking,shift2);
                 }
               // Found wave
               if(shift2_priceMax-shift2_priceMin>=0.33 *(shift2_priceMax-priceMin))
                 {
                  impulse.timeStart=shift2_priceMaxTime;
                  impulse.timeEnd=priceMinTime;
                  impulse.price_Start=shift2_priceMax;
                  impulse.price_End=priceMin;
                  impulse.length=impulse.price_End-impulse.price_Start;
                  impulse.duration=impulse.timeEnd-impulse.timeStart;
                  impulse.direction=OP_SELL;
                  return (true);
                 }
              }


           }
        }

     }

   return (false);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

WavesClass::FindOpposite(int o_direction,int o_impulseTimeStart,int o_impulseTimeEnd,double o_impulsePriceEnd)
  {

   double o_minutes=MathAbs(o_impulseTimeEnd-o_impulseTimeStart)/60;

   int o_workingTimeframe=0;

   for(int tf_num=9; tf_num>=1; tf_num--)
     {
      if(o_minutes/tf[tf_num]>=3)
        {
         o_workingTimeframe=tf[tf_num];
         break;
        }
     }

   int timeLater,timeEarlier;

   if(o_impulseTimeEnd<=o_impulseTimeStart)
     {
      timeEarlier=o_impulseTimeEnd;
      timeLater=o_impulseTimeStart;
     }
   else
     {
      timeEarlier=o_impulseTimeStart;
      timeLater=o_impulseTimeEnd;
     }

   int shiftStart=iBarShift(Symbol(),timeframeWorking,timeEarlier,false);



  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int WavesClass::FindAll(int s_direction,double r_lengthMin)
  {
   int shift=1;
   int tf_local=timeframeWorking;

   int shift_impulse_Start          = 0;
   int shift_impulse_Start_tf       = 0;
   int shift_impulse_End            = 0;
   int shift_impulse_End_tf         = tf_local;
   int shift_opposite_Start=0;  // opposite_End = impulse_Start
   int shift_opposite_Start_tf      = tf_local;
   int shift_opposite_Start_033     = 0;
   int shift_majorImpulse_Start     = 0;
   int shift_majorImpulse_Start_tf  = tf_local;
   int shift_majorImpulse_End       = 0;
   int shift_majorImpulse_End_tf    = tf_local;

   double price_impulse_Start       = iLow (Symbol (), tf_local, shift);
   double price_impulse_End         = iHigh (Symbol (), tf_local, shift);
   double price_opposite_Start      = 0;
   double price_opposite_Start_033  = 0;
   double price_majorImpulse_Start  = 0;
   double price_majorImpulse_End    = 0;

   int time_impulse_Start           = iTime (Symbol (), tf_local, shift);
   int time_impulse_End             = iTime (Symbol (), tf_local, shift);
   int time_opposite_Start          = 0;
   int time_opposite_Start_033      = 0;
   int time_majorImpulse_Start      = 0;
   int time_majorRetrace_End        = 0;

   double price_impulse_Start_Prev;
   double price_impulse_End_Prev;
   double price_opposite_Start_Prev;

   bool impulse_found               = false;
   bool opposite_found              = false;
   bool opposite_found_033          = false;
   bool majorRetrace_found          = false;
   bool majorImpulse_found          = false;

   if(s_direction==OP_BUY)
     {
      while(shift<seekShiftMax && !opposite_found_033)
        {
         // 1. FIND IMPULSE WAVE
         if(!impulse_found)
           {
            // 1.1. Find and refresh new Higher High of a wave (Impulse end)
            if(iHigh(Symbol(),tf_local,shift)>price_impulse_End)
              {
               price_impulse_End       = iHigh (Symbol(), tf_local, shift);
               price_impulse_Start     = iHigh (Symbol(), tf_local, shift);
               time_impulse_End        = iTime (Symbol(), tf_local, shift);
               time_impulse_Start      = iTime (Symbol(), tf_local, shift);
               shift_impulse_End       = shift;
               shift_impulse_End_tf    = tf_local;
              }
            // 1.2. Find the nearest Low where Impulse wave will be long enough
            // 1.2.1. Find and refresh new low
            if(iLow(Symbol(),tf_local,shift)<price_impulse_Start)
              {
               price_impulse_Start     = iLow (Symbol(), tf_local, shift);
               time_impulse_Start      = iTime (Symbol(), tf_local, shift);
               shift_impulse_Start     = shift;
               shift_impulse_Start_tf  = tf_local;
              }
            // 1.2.2. Check if the current wave length is long enough
            if(price_impulse_End-price_impulse_Start>=r_lengthMin
               && time_impulse_Start<time_impulse_End
               && (time_impulse_End-time_impulse_Start)/60<=dealDurationMax)
              {          // check 
               impulse_found=true;
               shift++;
              }
           }

         // 2. FIND OPPOSITE WAVE            
         if(impulse_found)
           {
            // 2.1. Find and refresh new Low of Opposite AND Impulse Wave
            if(iLow(Symbol(),tf_local,shift)<price_impulse_Start)
              {
               price_impulse_Start     = iLow (Symbol(), tf_local, shift);
               price_opposite_Start    = iLow (Symbol(), tf_local, shift);
               time_impulse_Start      = iTime (Symbol(), tf_local, shift);
               time_opposite_Start     = iTime (Symbol(), tf_local, shift);
               shift_impulse_Start     = shift;
               shift_impulse_Start_tf  = tf_local;
              }
            // 2.2. Find and refresh new High of the Opposite Wave
            if(iHigh(Symbol(),tf_local,shift)>price_opposite_Start)
              {
               price_opposite_Start    = iHigh (Symbol(), tf_local, shift);
               time_opposite_Start     = iTime (Symbol(), tf_local, shift);
               shift_opposite_Start    = shift;
               shift_opposite_Start_tf = tf_local;
              }
            // 2.3. Check if High of the Opposite wave is higher then Impulse End
            if(price_opposite_Start>price_impulse_End
               && time_opposite_Start<time_impulse_Start)
              {
               opposite_found=true;
               shift++;
              }
           }
         // 2.4. Seeking for the nearest opposite wave to the opposite wave no less than 33% of opposite wave length
         // So that the opposite wave was obvious
         if(opposite_found)
           {
            if(iLow(Symbol(),tf_local,shift)<price_opposite_Start)
              {
               price_opposite_Start_033   = iLow (Symbol(), tf_local, shift);
               time_opposite_Start_033    = iTime (Symbol(), tf_local, shift);
              }
            if(iHigh(Symbol(),tf_local,shift)>price_opposite_Start)
              {
               price_opposite_Start       = iHigh (Symbol(), tf_local, shift);
               time_opposite_Start        = iTime (Symbol(), tf_local, shift);
               price_opposite_Start_033   = iHigh (Symbol(), tf_local, shift);
               time_opposite_Start_033    = iTime (Symbol(), tf_local, shift);
               shift_opposite_Start       = shift;
               shift_opposite_Start_tf    = tf_local;
              }
            if(price_opposite_Start-price_opposite_Start_033>=0.33 *(price_opposite_Start-price_impulse_Start)
               && time_opposite_Start_033<time_opposite_Start)
              {
               opposite_found_033=true;
              }
           }

         // Setting impulse and opposite waves variables
         if(opposite_found_033)
           {

            // 1. Decompressing Impulse wave _End
            if(shift_impulse_End_tf>timeframeWorking
               && price_impulse_End!=price_impulse_End_Prev) // Work time optimization
              {
               shift_impulse_End= Decompress(HIGHERHIGH,shift_impulse_End_tf,shift_impulse_End,timeframeWorking);
               time_impulse_End = iTime(Symbol(),timeframeWorking,shift_impulse_End);
               //Print ("After decompression Impulse_End. shift_impulse_End="+shift_impulse_End+"   time ="+Get_date_string (time_impulse_End)+"   shift_impulse_End_tf="+shift_impulse_End_tf);
              }

            // 2. Decompressing Impulse wave _Start
            if(shift_impulse_Start_tf>timeframeWorking
               && price_impulse_Start!=price_impulse_Start_Prev)
              {
               shift_impulse_Start= Decompress(LOWERLOW,shift_impulse_Start_tf,shift_impulse_Start,timeframeWorking);
               time_impulse_Start = iTime(Symbol(),timeframeWorking,shift_impulse_Start);
               //Print ("After decompression Impulse_Start. shift_impulse_Start="+shift_impulse_Start+"   time ="+Get_date_string (time_impulse_Start)+"   shift_impulse_End_tf="+shift_impulse_End_tf);
              }

            // 3. Decompressing Opposite wave _Start
            if(shift_opposite_Start_tf>timeframeWorking
               && price_opposite_Start!=price_opposite_Start_Prev)
              {
               shift_opposite_Start= Decompress(HIGHERHIGH,shift_opposite_Start_tf,shift_opposite_Start,timeframeWorking);
               time_opposite_Start = iTime(Symbol(),timeframeWorking,shift_opposite_Start);
               //Print ("After decompression opposite_Start.  shift_opposite_Start="+shift_opposite_Start+"   time ="+Get_date_string (time_opposite_Start)+"   shift_opposite_Start_tf="+shift_opposite_Start_tf);
              }

            retrace.timeStart = iTime (Symbol(), tf_local, shift_impulse_Start);
            retrace.timeEnd   = iTime (Symbol(), tf_local, shift_impulse_End);
            retrace.price_Start=price_impulse_End;
            retrace.price_End = iLow (Symbol(), tf_local, shift_impulse_End);
            retrace.price_130 = retrace.price_Start + 0.33 * MathAbs (retrace.length);
            retrace.price_150 = retrace.price_Start + 0.5 * MathAbs (retrace.length);
            retrace.price_033 = retrace.price_End + 0.33 * MathAbs (retrace.length);
            retrace.price_050 = retrace.price_End + 0.5 * MathAbs (retrace.length);
            retrace.price_066 = retrace.price_End + 0.66 * MathAbs (retrace.length);
            retrace.length=retrace.price_End-retrace.price_Start;
            retrace.duration=retrace.timeEnd-retrace.timeStart;
            retrace.direction=OP_SELL;
            retrace.tfMax=TF_Max(retrace.timeStart,retrace.timeEnd);

            impulse.timeStart=time_impulse_Start;
            impulse.timeEnd=time_impulse_End;
            impulse.price_Start=price_impulse_Start;
            impulse.price_End=price_impulse_End;
            impulse.length=impulse.price_End-impulse.price_Start;
            impulse.duration=impulse.timeEnd-impulse.timeStart;
            impulse.direction = OP_BUY;
            impulse.price_130 = impulse.price_Start - 0.33 * MathAbs (impulse.length);
            impulse.price_150 = impulse.price_Start - 0.5 * MathAbs (impulse.length);
            impulse.price_033 = impulse.price_Start + 0.66 * MathAbs (impulse.length);
            impulse.price_050 = impulse.price_Start + 0.5 * MathAbs (impulse.length);
            impulse.price_066 = impulse.price_Start + 0.33 * MathAbs (impulse.length);
            impulse.price_goal_3w=opposite.price_End+impulse.length;
            impulse.tfMax=TF_Max(impulse.timeStart,impulse.timeEnd);

            opposite.timeStart=time_opposite_Start;
            opposite.price_Start=iHigh(Symbol(),timeframeWorking,shift_opposite_Start);
            opposite.timeEnd=impulse.timeStart;
            opposite.price_End=impulse.price_Start;
            opposite.length=opposite.price_End-opposite.price_Start;
            opposite.duration=opposite.timeEnd-opposite.timeStart;
            opposite.direction = OP_SELL;
            opposite.price_130 = opposite.price_Start + 0.33 * MathAbs (opposite.length);
            opposite.price_150 = opposite.price_Start + 0.5 * MathAbs (opposite.length);
            opposite.price_033 = opposite.price_End + 0.33 * MathAbs (opposite.length);
            opposite.price_050 = opposite.price_End + 0.50 * MathAbs (opposite.length);
            opposite.price_066 = opposite.price_End + 0.66 * MathAbs (opposite.length);
            opposite.tfMax=TF_Max(opposite.timeStart,opposite.timeEnd);

            Visualize_Draw("ImpulseWave",impulse.timeStart,impulse.timeEnd,impulse.price_Start,impulse.price_End,Green,1);
            Visualize_Draw("OppositeWave",opposite.timeStart,opposite.timeEnd,opposite.price_Start,opposite.price_End,Red,1);

            //               double price_chart = ObjectGetValueByTime (ChartID(),"ImpulseWave",TimeCurrent (),0);
            //   
            //               // Initializing line formula
            //               double delta = (impulse.price_End - impulse.price_Start) / MathAbs (impulse.timeStart - impulse.timeEnd);
            //               double y_price_calc = impulse.price_Start + (TimeCurrent () - impulse.timeStart) * delta;
            //               
            //               Print ("delta="+delta+"   y_price_calc="+y_price_calc+"   price_chart="+price_chart);

           }

         // Compressing timeframes
         shift++;
         int tfh=TF_Higher(tf_local);
         if(tf_local!=0  &&  tfh!=0)
           {
            if(shift>=4*tfh/tf_local)
              {
               shift = MathFloor(shift * tf_local / tfh);
               tf_local=tfh;
              }
           }
         if(impulse_found && opposite_found_033) return (1);
         if(impulse_found && (time_impulse_End - time_impulse_Start) > dealDurationMax * 60) return (0);
        }
     }

   return (0);

  }
//+------------------------------------------------------------------+
//| Visualizing found waves                                          |
//| -- v_type=1 - draw line
//| -- v_type=2 - draw rectangle
//+------------------------------------------------------------------+

WavesClass::Visualize_Draw(string v_name,int v_timeStart,int v_timeEnd,double v_priceStart,double v_priceEnd,color v_color,int v_type)
  {

   if(v_type==1) // Draw lines
     {
      ObjectDelete(v_name);
      ObjectCreate(v_name,OBJ_TREND,0,v_timeStart,v_priceStart,v_timeEnd,v_priceEnd);
      ObjectSet(v_name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSet(v_name,OBJPROP_WIDTH,2);
      ObjectSet(v_name,OBJPROP_RAY,false);
      ObjectSet(v_name,OBJPROP_COLOR,v_color);
     }

   if(v_type==2) // Draw lines
     {
      ObjectCreate(v_name,OBJ_RECTANGLE,0,0,v_timeStart,v_priceStart,v_timeEnd,v_priceEnd);
      ObjectSet(v_name,OBJPROP_BACK,true);
      ObjectSet(v_name,OBJPROP_RAY,false);
      ObjectSet(v_name,OBJPROP_COLOR,v_color);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

WavesClass::Visualize_Clear(string c_name)
  {

   for(int pv=ObjectsTotal(); pv>=0; pv--)
     {
      if(ObjectName(pv)==c_name) ObjectDelete(pv);
      break;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


string WavesClass::Get_date_string(int time_input)
  {

   string string_result=StringConcatenate(TimeYear(time_input),".",TimeMonth(time_input),".",TimeDay(time_input),"   ",TimeHour(time_input),":",TimeMinute(time_input));

   if(time_input==0) string_result="0";

   return (string_result);

  }
//+------------------------------------------------------------------+
//| TF Functions
//+------------------------------------------------------------------+


int WavesClass::TF_Lower(int l_timeframe)
  {
   for(int t=2; t<=9; t++)
     {
      if(tf[t] == l_timeframe) return (tf[t-1]);
     }
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int WavesClass::TF_Higher(int h_timeframe)
  {
   for(int t=8; t>=1; t--)
     {
      if(tf[t] == h_timeframe) return (tf[t+1]);
     }
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int WavesClass::TF_Number(int n_timeframe)
  {
   for(int t=9; t>=1; t--)
     {
      if(tf[t] == n_timeframe) return (t);
     }
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int WavesClass::TF_Max(int x_timeEarlier,int x_timeLater)
  {
   for(int t=9; t>=1; t--)
     {
      if((x_timeLater - x_timeEarlier)/60/tf[t]>=2) return (tf[t]);
     }
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int WavesClass::FindCascade(int c_direction,int c_minorWaveLengthMin,int c_majorWaveDurationMax,int c_drawWaves)
  {
// Find BUY cascade
   if(c_direction==OP_BUY)
     {

      int      tfLocal        = timeframeWorking;
      double   priceMax       = iHigh (Symbol(), tfLocal, 1);
      double   priceMin       = iLow (Symbol(), tfLocal, 1);
      int      timeMax        = iTime (Symbol(), tfLocal, 1);
      int      timeMin        = iTime (Symbol(), tfLocal, 1);
      int      shiftMin;
      int      shiftMax;
      int      shift          = 1;
      int      impulseCount   = 0;
      int      seekDirection  = OP_BUY;
      double   checkPrice     = priceMax - c_minorWaveLengthMin;
      double	checkLength = c_minorWaveLengthMin;


      int      waveEnd_TF;
      int      waveStart_TF;
      int      waveEnd_Time   = 0;
      int      waveStart_Time = 0;
      int      waveEnd_Shift;
      int      waveStart_Shift;
      double   waveEnd_Price;
      double   waveStart_Price;

      while(shift<=seekShiftMax)
        {
         // Compressing timeframes
         int tfh=TF_Higher(tfLocal);
         if(tfLocal!=0 && tfh!=0)
           {
            if(shift*tfLocal/tfh>=4)
              {
               shift=MathFloor(shift*tfLocal/tfh);
               //Print ("Compressing to "+tfh);
               tfLocal=tfh;
              }
           }
         // Seeking BUY direction
         if(seekDirection==OP_BUY)
           {
            if(iHigh(Symbol(),tfLocal,shift)>priceMax)
              { // Found wave BUY End
               priceMax = iHigh (Symbol(), tfLocal, shift);
               priceMin = iHigh (Symbol(), tfLocal, shift);
               timeMax  = iTime (Symbol(), tfLocal, shift);
               timeMin  = iTime (Symbol(), tfLocal, shift);
               shiftMin = shift;
               shiftMax = shift;
               // Find the minor wave first
               if(impulseCount==0) {
		   checkPrice=priceMax-c_minorWaveLengthMin;
		   Print ("checkPrice="+checkPrice);
	       }
              }
            if(iLow(Symbol(),tfLocal,shift)<priceMin)
              { // Found wave BUY Start
               priceMin = iLow (Symbol(), tfLocal, shift);
               timeMin  = iTime (Symbol(), tfLocal, shift);
               shiftMin = shift;
               // Exit loop if wave duration exceeds 'dealDurationMax'
               if((timeMax-timeMin)/60>dealDurationMax) break;
              }
           }
         // Seeking SELL direction
         if(seekDirection==OP_SELL)
           {
            if(iLow(Symbol(),tfLocal,shift)<priceMin)
              {
               priceMax = iLow (Symbol(), tfLocal, shift);
               priceMin = iLow (Symbol(), tfLocal, shift);
               timeMax  = iTime (Symbol(), tfLocal, shift);
               timeMin  = iTime (Symbol(), tfLocal, shift);
               shiftMin = shift;
               shiftMax = shift;
               // Exit loop if wave duration exceeds 'dealDurationMax'
               if((waveEnd_Time-timeMin)/60>dealDurationMax) break;
              }
            if(iHigh(Symbol(),tfLocal,shift)>priceMax)
              {
               priceMax= iHigh(Symbol(),tfLocal,shift);
               timeMax = iTime(Symbol(),tfLocal,shift);
               shiftMax= shift;
              }
           }
	 
	 // If found wave with enough length - impulse++
	 if (seekDirection == OP_BUY 
	 && timeMax > timeMin
	 && priceMin < checkPrice){
	    impulseCount++;
	    cascade.impulse[impulseCount].price_End = priceMax;
	    cascade.impulse[impulseCount].timeEnd = timeMax;
	    cascade.impulse[impulseCount].tf_End = tfLocal;
	    cascade.impulse[impulseCount].shift_End = shift;
	    seekDirection = OP_SELL;
	 }
	 
         // Check find impulse BUY Start (full wave found)
         if(seekDirection==OP_SELL
            && priceMax>checkPrice
	    && timeMax < timeMin)
           {  // Found impulse Start
	       cascade.impulse[impulseCount].timeStart = timeMin;
	       cascade.impulse[impulseCount].price_Start = priceMin;
	       cascade.impulse[impulseCount].tf_Start = tfLocal;
	       cascade.impulse[impulseCount].shift_Start = shiftMin;
		
            Print("Found wave #"+impulseCount+": tfStart="+priceMin+"   tfEnd="+tfLocal+"   timeStart="+Get_date_string(timeMin)+"   timeEnd="+Get_date_string(cascade.impulse[impulseCount].timeEnd)+"   price_Start="+priceMin+"   price_End="+waveEnd_Price+"   length="+(waveEnd_Price-waveStart_Price));
            // Setting found wave variables
            // Decompressing impulse wave Start
            if(cascade.impulse[impulseCount].tf_Start > timeframeWorking)
              {
               //int shiftStart=waveStart_Shift*waveStart_TF/timeframeWorking+iBarShift(Symbol(),timeframeWorking,iTime(Symbol(),waveStart_TF,1),false);
               //int shiftEnd=(waveStart_Shift-1)*waveStart_TF/timeframeWorking+iBarShift(Symbol(),timeframeWorking,iTime(Symbol(),waveStart_TF,1),false);
	       int shiftStart = Decompress(LOWERLOW, cascade.impulse[impulseCount].tf_Start, cascade.impulse[impulseCount].shift_Start, timeframeWorking);
	       int shiftEnd = Decompress (HIGHERHIGH, cascade.impulse[impulseCount].tf_End, cascade.impulse[impulseCount].shift_End, timeframeWorking);
               cascade.impulse[impulseCount].tf_Start = iLowest(Symbol(),timeframeWorking,MODE_LOW,shiftStart-shiftEnd,shiftEnd);
//               Print("Decompressed waveStart from TF"+waveStart_TF+": shiftStart="+shiftStart+"   shiftEnd="+shiftEnd+"   waveStart_Shift="+waveStart_Shift);
              }
            // Decompressing impulse wave End
            if(cascade.impulse[impulseCount].tf_End > timeframeWorking)

              {
               shiftStart=waveEnd_Shift*waveEnd_TF/timeframeWorking+iBarShift(Symbol(),timeframeWorking,iTime(Symbol(),waveEnd_TF,1),false);
               shiftEnd=(waveEnd_Shift-1)*waveEnd_TF/timeframeWorking+iBarShift(Symbol(),timeframeWorking,iTime(Symbol(),waveEnd_TF,1),false);
               cascade.impulse[impulseCount].tf_End = iHighest(Symbol(),timeframeWorking,MODE_HIGH,shiftStart-shiftEnd,shiftEnd);
               //Print ("DecompressedTF+ waveEnd from TF"+waveEnd_": shiftStart="+shiftStart+"   shiftEnd="+shiftEnd+"   waveEnd_Shift="+waveEnd_Shift);
              }
            cascade.impulse[impulseCount].duration    = cascade.impulse[impulseCount].timeEnd - cascade.impulse[impulseCount].timeStart;
            cascade.impulse[impulseCount].length      = cascade.impulse[impulseCount].price_End - cascade.impulse[impulseCount].price_Start;
            checkPrice        = cascade.impulse[impulseCount].price_Start;
            seekDirection     = OP_BUY;
           }
         shift++;
        }
      // Draw waves
      for(int i=1; i<=impulseCount; i++)
        {
         Visualize_Draw("ImpulseWave+"+i,cascade.impulse[i].timeStart,cascade.impulse[i].timeEnd,cascade.impulse[i].price_Start,cascade.impulse[i].price_End,Green,1);
         //Print ("Drawing waves: timeStart="+Get_date_string(cascade.impulse[i].timeStart)+"   timeEnd="+Get_date_string(cascade.impulse[i].timeEnd)+"   price_Start="+cascade.impulse[i].price_Start+"   price_End="+cascade.impulse[i].price_End,Red);
        }

     }
   return (impulseCount);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int WavesClass::Decompress(int extremumType,int timeframeSource,int shiftSource,int timeframeTarget)
  {
   int shiftTarget;
   int shift_Earlier;
   int shift_Later;
   shift_Earlier=shiftSource*timeframeSource/timeframeTarget+iBarShift(Symbol(),timeframeTarget,iTime(Symbol(),timeframeSource,1),false);
   shift_Later=(shiftSource-1) * timeframeSource/timeframeTarget;
   if(extremumType==LOWERLOW)
     {
      shiftTarget = iLowest(Symbol(),timeframeTarget,MODE_LOW,shift_Earlier-shift_Later,shift_Later);
     }
   if(extremumType==HIGHERHIGH)
     {
      shiftTarget = iHighest(Symbol(),timeframeTarget,MODE_HIGH,shift_Earlier-shift_Later,shift_Later);
     }
//   Print("Decompression result: shift target="+shiftTarget);
   return (shiftTarget);
  }
//+------------------------------------------------------------------+
