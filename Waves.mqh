
//|                                                    Q10NIK EXPERT |
//|                                   Copyright 2016, Zhinzhich Labs |


class WavesClass
    {
    private:
    double  PeriodMin();
    double  LengthMin();
    double  Costs();
    double  dealCostsMax;
    double  dealRiskCostsKoef;
    int     seekShiftMax;
    int     timeframeWorking;
    int     dealDurationMax;
    bool    visualizeWaves;
    int     tf[10];
    int     compressedShift;
    int     compressedTime;
    int     compressedTimeframe;
    
    void    Visualize_Draw(string v_name,int v_timeStart,int v_timeEmd,double v_priceStart,double v_priceEnd,color v_color,int v_type);
    void    Visualize_Clear(string c_name);
    string  Get_date_string(int time_input);
    int     TF_Number(int n_timeframe);
    int     TF_Lower(int l_timeframe);
    int     TF_Higher(int h_timeframe);
    int     TF_Max(int x_timeEarlier,int x_timeLater);
    void    TF_Init();

    // DEFAULT PARAMETERS
    #define _decompressionTimeframeRatioMax 40
    #define _timeframeWorking 1
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
    #define _compressionTFKoefMax 240

    public:

    struct waveStruct{
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
        int				tf_Start;
        int               shift_Start;
        int				shift_End;
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

    struct pushStruct{
        int             timeStart_Wave_1;
        int             timeStart_Wave_3;
        int             timeEnd_Wave_1;
        int             timeEnd_Wave_3;
        int             duration_Total;
        int             duration_2touch;
        int             duration_Wave_1;
        int             duration_Wave_2;
        int             duration_Wave_3;
        double          priceStart_Wave_1;
        double          priceStart_Wave_3;
        double          priceEnd_Wave_1;
        double          priceEnd_Wave_3;
        double          length_Wave_1;
        double          length_Wave_2;
        double          length_Wave_3;
        double          retraceRatio;             // Retrace ratio from the 1st wave of the push
    };

	// Methods

    // Find push (2nd touch)
    bool    FindPush (int     direction, 
                      int     timeframe,
                      int     timeStartToSeek,              // Time from which push will be searched
                      int     timeStartMin,                 // Minimum time from where the push must start (necessary in case of finding total grand 3-waves)
                      double  lengthMin, 
                      double  retraceRatioMin,                // Minimum retrace after the 1st push wave
                      int     touchDurationKoefMin);          // Minimum koef for touch duration in the push (1.0 - 3rd wave of the push no earlier than the duration of 1st wave end and nearest opposing high|low)

    // Find waves cascade
    int     FindCascade (int c_direction,
                         int c_minorWaveLengthMin,
                         int c_majorWaveDurationMax,
                         int c_drawWaves);

    // Find 2 waves (impulse + correction)
    int     FindAll (int s_direction,
                     double r_lengthMin);
    
    // Find 2 waves (impulse + correction) _new
	int     FindAll2 (int directionLocal, 
                      double wave_length_min);

    // Find corrector of a wave
	double  FindCorrector (int c_timeframe, 
                           int c_direction, 
                           int c_timeStart, 
                           int c_timeEnd);

    // Find 2 waves by minimum length _deprecated?
    bool    FindByLength (int f_direction,
                          double r_lengthMin,
                          int r_timeEndMax);

    bool    FindInPeriod(double periodMin);

    bool    FindByTime(int timeEnd);

    double  RetraceRatioMax(int r_direction,int r_timeStart,int r_timeEnd,double r_priceStart,double r_priceEnd);
    void    Init(int timeframeWorking,int seekShiftMax,double dealCostsMax,int dealDurationMax,int visualizeWaves);
    void    FindMajor(int m_direction,int m_minorTimeStart); // Find major wave to the seeked one
    void    FindOpposite(int o_direction,int o_impulseTimeStart,int o_impulseTimeEnd,double o_impulsePriceEnd);
    bool    waveFind(int param);
    void    Compress(int compressRatio,int extremumType,int timeframeSource,int shiftSource);
    int     Decompress(int extremumType,int timeframeSource,int shiftSource,int timeframeTarget);
    double  CandleAverageBody();
    double  DirectionRatio();
    bool    FindByLength_Compressed(int f_direction,double r_lengthMin,int r_timeEndMax);

    // Initialize data structures and subclasses
    waveStruct        impulse;
    waveStruct        major;
    waveStruct        majorRetrace;
    waveStruct        opposite;
    waveStruct        retrace;
    waveStruct        wave[10];

    cascadeStruct     cascade;

    pushStruct       push;                       // Current push parameters
    pushStruct       push_prev;                  // Previous push parameters

    // Main class constructor
    WavesClass(int _tfWork, int _seekShiftMax, double _dealCostsKoefMax, int _dealDurationMax);

  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

WavesClass::WavesClass(int _tfWork, int _seekShiftMax, double _dealCostsKoefMax, int _dealDurationMax);

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

    timeframeWorking    = _tfWork;
    seekShiftMax        = _seekShiftMax;
    dealRiskCostsKoef   = _dealCostsKoefMax;
    dealDurationMax     = _dealDurationMax;

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
//|                                                                  |
//+------------------------------------------------------------------+

double WavesClass::RetraceRatioMax(int r_direction,int r_timeEarlier,int r_timeLater,double r_priceEarlier,double r_priceLater)
  {

	//+------------------------------------------------------------------+
	//| Retrace Ratio Max                                                |
	//| -- Calculates the maximum retrace during the wave (e.g. 0.32)    |
	//| -- The lower the maximum retrace - the stronger the wave         |
	//+------------------------------------------------------------------+

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
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+

WavesClass::Visualize_Draw(string v_name,int v_timeStart,int v_timeEnd,double v_priceStart,double v_priceEnd,color v_color,int v_type)
  {

	//+------------------------------------------------------------------+
	//| Visualizing found waves                                          |
	//| -- v_type=1 - draw line
	//| -- v_type=2 - draw rectangle
	//+------------------------------------------------------------------+

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
//|                                                                  |
//+------------------------------------------------------------------+

int WavesClass::TF_Lower(int l_timeframe){
    for(int t=2; t<=9; t++){
        if(tf[t] == l_timeframe) return (tf[t-1]);
    }
    return (0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int WavesClass::TF_Higher(int h_timeframe){
    for(int t=8; t>=1; t--){
        if(tf[t] == h_timeframe) return (tf[t+1]);
    }
    return (0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int WavesClass::TF_Number(int n_timeframe){
    for(int t=9; t>=1; t--){
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
  
  
  
//// Find BUY cascade
//   if(c_direction==OP_BUY)
//     {
//
//      int      tfLocal        = timeframeWorking;
//	  int		tfMin		= tfLocal;
//	  int		tfMax		= tfLocal;
//	  double   priceMax       = iHigh (Symbol(), tfLocal, 1);
//      double   priceMin       = iLow (Symbol(), tfLocal, 1);
//      int      timeMax        = iTime (Symbol(), tfLocal, 1);
//      int      timeMin        = iTime (Symbol(), tfLocal, 1);
//      int      shiftMin;
//      int      shiftMax;
//      int      shift          = 1;
//      int      impulseCount   = 0;
//      int      seekDirection  = OP_BUY;
//      double   checkPrice     = priceMax - c_minorWaveLengthMin * Point;
//      double	checkLength = c_minorWaveLengthMin;
//	  int		tfh;
//
//	  int		hh_shift=shift;
//	  int		hh_tf=tfLocal;
//	  int		hh_time = iTime (Symbol(), tfLocal, 1);
//	  double	hh_price = iHigh (Symbol(), tfLocal, 1);
//
//	  int		ll_shift=shift;
//	  int		ll_tf=tfLocal;
//	  int		ll_time=iTime (Symbol(), tfLocal, 1);
//	  double	ll_price = iLow (Symbol(), tfLocal, 1);
//	  
//	  bool wave_buy_start_found 	= false;
//	  bool wave_sell_start_found 	= false;
//	  bool wave_buy_end_found 	= false;
//	  bool wave_sell_end_found 	= false;
//
//		double wave_buy_start_price;
//		int wave_buy_start_time;
//		int wave_buy_start_shift;
//		int wave_buy_start_tf;
//
//		double wave_sell_start_price;
//		int wave_sell_start_time;
//		int wave_sell_start_shift;
//		int wave_sell_start_tf;
//		bool impulse_start_found;
//		bool impulse_end_found;
//
//	  double priceLowest = priceMin;	// Lowest price after the Wave End - for finding nulllified waves
//	  double priceHighest = priceMax;	// Highest  price after the Wave End
//
//      int      waveEnd_TF;
//      int      waveStart_TF;
//      int      waveEnd_Time   = 0;
//      int      waveStart_Time = 0;
//      int      waveEnd_Shift;
//      int      waveStart_Shift;
//      double   waveEnd_Price;
//      double   waveStart_Price;
//	  double	wave_Length;
//
//
//      while(shift<=seekShiftMax)
//        {
//
//         // Seeking BUY direction: lower low lengthens wave, higher high refreshes waveEnd
//         if(seekDirection==OP_BUY)
//           {
//            if(iHigh(Symbol(),tfLocal,shift)>hh_price){
//				hh_time = iTime (Symbol(), tfLocal, shift);
//				hh_price = iHigh(Symbol(),tfLocal,shift);
//				hh_shift = shift;
//				hh_tf = tfLocal;
//
//				impulse_start_found = false;
//
//				// Check if it's time to compress hh
//				tfh=TF_Higher (tfLocal);
//			  	if (hh_time - ll_time  >= 60 * 3 * tfh
//				  && tfh != 0){
//				// Compressing timeframe
//               	hh_shift = MathFloor(shift * tfLocal / tfh);
//				hh_time = iTime (Symbol(), tfLocal, hh_shift);
//				hh_tf = tfh;
//				tfLocal = tfh;
//				}
//				}
//
//            if(iLow(Symbol(),tfLocal,shift)<ll_price){
//				ll_time = iTime (Symbol(), tfLocal, shift);
//				ll_price = iLow(Symbol(),tfLocal,shift);
//				ll_shift = shift;
//				ll_tf = tfLocal;
//
//				// Check if it's time to compress ll
//				tfh=TF_Higher (tfLocal);
//			  	if (hh_time - ll_time  >= 60 * 3 * tfh
//				  && tfh != 0){
//				  // Compressing timeframe
//               	ll_shift = MathFloor(shift * tfLocal / tfh);
//				ll_time = iTime (Symbol(), tfLocal, hh_shift);
//				ll_tf = tfh;
//				tfLocal = tfh;
//				}
//			  wave_Length = hh_price - ll_price;
//			  if (ll_price < checkPrice){
//				  // Found start of a buy wave
//				  impulseCount++;
//				  impulse_start_found = true;
//				  waveBuy_StartFound = true;
//			  impulse[impulseCount].price_Start = hh_price;
//			  impulse[impulseCount].timeStart = hh_time;
//			  impulse[impulseCount].shift_Start = hh_shift;
//			  impulse[impulseCount].tf_Start = hh_tf;
//
//
//				  }
//
//			  if (checkLength < c_minorWaveLengthMin) checkLength = c_minorWaveLengthMin; 
//			  if (wave_Length > checkLength){
//
//				}
//				  
//			   // Find waveBuy_Start
//              if(iHigh(Symbol(),tfLocal,shift)>priceMax)
//              { // Found wave BUY End
//			  priceMax = iHigh (Symbol(), tfLocal, shift);
//              timeMax  = iTime (Symbol(), tfLocal, shift);
//
//			  // Check if Compression needed for Higher High
//				tfh = TF_Higher (tfLocal);
//			  if (timeMax - timeMin >= 60 * 3 * tfh
//				  && tfh != 0){
//				  // Compressing timeframe
//               	shiftMax = MathFloor(shift * tfLocal / tfh);
//				tfLocal=tfh;
//				tfMax = tfh;
//              	timeMax  = iTime (Symbol(), tfLocal, shiftMax);
//				}
//               priceMin = iHigh (Symbol(), tfLocal, shift);
//               timeMin  = iTime (Symbol(), tfLocal, shift);
//               shiftMin = shift;
//			   tfMin	= tfLocal;
//			  checkLength = priceMax - priceLowest;
//			  if (checkLength < c_minorWaveLengthMin) checkLength = c_minorWaveLengthMin; 
//	       		}
//              }
//            if(iLow(Symbol(),tfLocal,shift)<priceMin)
//              { // Found wave BUY Start
//               priceMin = iLow (Symbol(), tfLocal, shift);
//               timeMin  = iTime (Symbol(), tfLocal, shift);
//               shiftMin = shift;
//			   tfMin = tfLocal;
//               // Exit loop if wave duration exceeds 'dealDurationMax'
//               if((timeMax-timeMin)/60>dealDurationMax) break;
//              }
//           }
//
//         // Seeking SELL direction: higher high lenthens opposite wave, lower low refreshes waveStart
//         if(seekDirection==OP_SELL)
//           {
//            if(iLow(Symbol(),tfLocal,shift)<priceMin)
//              {
//               priceMax = iLow (Symbol(), tfLocal, shift);
//               priceMin = iLow (Symbol(), tfLocal, shift);
//               timeMax  = iTime (Symbol(), tfLocal, shift);
//               timeMin  = iTime (Symbol(), tfLocal, shift);
//               shiftMin = shift;
//               shiftMax = shift;
//               // Exit loop if wave duration exceeds 'dealDurationMax'
//               if((waveEnd_Time-timeMin)/60>dealDurationMax) break;
//              }
//            if(iHigh(Symbol(),tfLocal,shift)>priceMax)
//              {
//               priceMax= iHigh(Symbol(),tfLocal,shift);
//               timeMax = iTime(Symbol(),tfLocal,shift);
//               shiftMax= shift;
//              }
//           }
//
//	// Initializing highest and lowest prices	 
//	if(priceMin < priceLowest) priceLowest = priceMin;
//	if(priceMax > priceHighest) priceHighest = priceMax; 
//	
//	 // If found wave with enough length
//	 if (seekDirection == OP_BUY 
//	 && timeMax > timeMin
//	 && priceMin < checkPrice){
//		waveEnd_Price = priceMax;
//		waveEnd_Time = timeMax;
//		waveEnd_Shift = shift;
//		waveEnd_TF = tfLocal;
//		checkPrice = waveEnd_Price; // Set check price for the maximum of the founded wave
//		seekDirection = OP_SELL;
//	 }
//	 
//         // Check find impulse BUY Start (full wave found)
//         if(seekDirection==OP_SELL
//            && priceMax>checkPrice
//	    && timeMax < timeMin)
//           {  // Found impulse Start
//			impulseCount++;
//			waveStart_Price = priceMin;
//			waveStart_Time = timeMin;
//			waveStart_Shift = shift;
//			waveStart_TF = tfLocal;
//			checkPrice = waveStart_Price; // Set check price for the minimum of the founded wave
//			seekDirection = OP_BUY;
//
//            Print("Found wave #"+impulseCount+": tfStart="+waveStart_TF+"   tfEnd="+waveEnd_TF+"   timeStart="+Get_date_string(waveStart_Time)+"   timeEnd="+Get_date_string(waveEnd_Time)+"   price_Start="+waveStart_Price+"   price_End="+waveEnd_Price+"   length="+(waveEnd_Price-waveStart_Price));
//            // Setting found wave variables
//            // Decompressing impulse wave Start
//            if(waveStart_TF > timeframeWorking)
//              {
//				  int minorStart_Shift = iBarShift(Symbol(),timeframeWorking,iTime(Symbol(),waveStart_TF,waveStart_Shift),true);
//				  int minorEnd_Shift = iBarShift(Symbol(),timeframeWorking,iTime(Symbol(),waveStart_TF,waveStart_Shift-1),true);
//				 Print ("Before decomp: waveStart_TF:"+waveStart_TF+"    waveStart_Shift"+waveStart_Shift+"   minorStart_Shift="+minorStart_Shift+"   minorEnd_Shift="+minorEnd_Shift);
//				  waveStart_Shift = iLowest (Symbol (),timeframeWorking, minorStart_Shift - minorEnd_Shift, minorEnd_Shift); 
//				  waveStart_TF = timeframeWorking;
//				  waveStart_Time = iTime (Symbol(),timeframeWorking,waveStart_Shift);
//
//               Print("Decompressed: waveStart_TF"+waveStart_TF+"   shiftStart="+waveStart_Shift+"   shiftEnd="+waveEnd_Shift);
//              }
//            // Decompressing impulse wave End
//            if(waveEnd_TF > timeframeWorking)
//
//              {
//
//				  minorStart_Shift = iBarShift(Symbol(),timeframeWorking,iTime(Symbol(),waveEnd_TF,waveEnd_Shift),true);
//				  minorEnd_Shift = iBarShift(Symbol(),timeframeWorking,iTime(Symbol(),waveEnd_TF,waveEnd_Shift-1),true);
//				  
//				  waveEnd_Shift = iHighest (Symbol (),timeframeWorking, minorStart_Shift - minorEnd_Shift, minorEnd_Shift); 
//				  waveEnd_TF = timeframeWorking;
//				  waveEnd_Time = iTime (Symbol(),timeframeWorking,waveEnd_Shift);
//
//               //Print ("DecompressedTF+ waveEnd from TF"+waveEnd_": shiftStart="+shiftStart+"   shiftEnd="+shiftEnd+"   waveEnd_Shift="+waveEnd_Shift);
//              }
//			  // Setting cascade class variables
//			  cascade.impulse[impulseCount].price_End = waveEnd_Price;
//			  cascade.impulse[impulseCount].price_Start = waveStart_Price;
//			  cascade.impulse[impulseCount].shift_End = waveEnd_Shift;
//			  cascade.impulse[impulseCount].timeEnd = waveEnd_Time;
//			  cascade.impulse[impulseCount].timeStart = waveStart_Time;
//
//            cascade.impulse[impulseCount].duration    = cascade.impulse[impulseCount].timeEnd - cascade.impulse[impulseCount].timeStart;
//            cascade.impulse[impulseCount].length      = cascade.impulse[impulseCount].price_End - cascade.impulse[impulseCount].price_Start;
//           }
//
//         // Compressing timeframes
//         int tfh=TF_Higher(tfLocal);
//         if(tfLocal!=0 && tfh!=0)
//           {
//            if(shift*tfLocal/tfh>=4)
//              {
//               shift=MathFloor(shift*tfLocal/tfh);
//               //Print ("Compressing to "+tfh);
//               tfLocal=tfh;
//              }
//           }
//         shift++;
//        }
//
//      // Draw waves
//      for(int i=1; i<=impulseCount; i++)
//        {
//         Visualize_Draw("ImpulseWave+"+i,cascade.impulse[i].timeStart,cascade.impulse[i].timeEnd,cascade.impulse[i].price_Start,cascade.impulse[i].price_End,Green,1);
//         //Print ("Drawing waves: timeStart="+Get_date_string(cascade.impulse[i].timeStart)+"   timeEnd="+Get_date_string(cascade.impulse[i].timeEnd)+"   price_Start="+cascade.impulse[i].price_Start+"   price_End="+cascade.impulse[i].price_End,Red);
//        }
//
//     }
//   return (impulseCount);
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
//|                                                                  |
//+------------------------------------------------------------------+

int WavesClass::FindAll2 (int directionLocal, double wave_length_min){
    if (directionLocal == OP_BUY){
        }
    return (0);
//
//        int     HH_shift = 0;
//        int     HH_tf = 1;
//        int     HH_time = iTime (Symbol(),HH_tf,0);
//        double  HH_price = iHigh (Symbol (), HH_tf, 0);
//
//        int     LL_shift = 0;
//        int     LL_tf = 1;
//        double  LL_price = iLow (Symbol (), LL_tf, 0);
//        int     LL_time = iTime (Symbol(),LL_tf,0);
//
//        int     SHIFT = 0;
//        int     TF = 1;
//
//        int     wave_count = 0;
//
//        double  high_price;
//        double  low_price;
//        int     high_time;
//        int     low_time;
//
//        int     tfh;
//
//        while (SHIFT <= seekShiftMax){
//            high_price = iHigh (Symbol(),TF,SHIFT); 
//            low_price = iLow (Symbol(),TF,SHIFT); 
//
//            // Check refresh current high
//            if (high_price > HH_price
//            && HH_time <= LL_time){
//                HH_tf = TF;
//                HH_shift = SHIFT;
//                HH_time = iTime (Symbol(),HH_tf, HH_shift);
//                HH_price = high_price;
//                // check / compress new HH
//                tfh = TF_Higher (HH_tf);
//            }
//            // Check refresh current high
//            if (high_price > HH_price
//            && HH_time <= LL_time                                // no low before the previous HH - no triangle, no new wave    
//            && high_price - LL_price > HH_price - LL_price
//            && high_price - LL_price >= minor_length_min){
//                // first check if it needs to compress the founded higher high
//                // if wave duration of sell wave is more that 2 full candles of the higher timeframe
//                // then compress to that higher timeframe
//                HH_tf = TF;
//                HH_shift = SHIFT;
//                HH_time = iTime (Symbol(),HH_tf, HH_shift);
//                HH_price = high_price;
//                // check compress new hh
//                int tfh = TF_Higher (HH_tf);
//                if (tfh > 0 && (HH_time - LL_time) / tfh / 60 >= 3){ // if >=2 full candles for sell wave - compressing new HH
//                    TF = tfh; 
//                    SHIFT = iBarShift (Symbol(),tfh,HH_time,false);
//                    HH_tf = TF;
//                    HH_shift = SHIFT;
//                    HH_time = iTime (Symbol(),TF,SHIFT);
//                }
//            }
//
//            // Check refresh current high
//            if (high_price > HH_price){
//                HH_tf = TF;
//                HH_shift = SHIFT;
//                HH_time = iTime (Symbol(),TF, SHIFT);
//                HH_price = high_price; 
//            }
//
//            // Compressing timeframes
//
//            if (low_price < LL_price
//            && HH_price - low_price > hh_price - LL_price
//            && HH_price - low_price >= minor_length_min) { // this is new ll - buy wave found, hh fixed
//                LL_tf = TF;_
//                LL_shift = SHIFT;
//                LL_time = iTime (Symbol(),TF, SHIFT);
//                LL_price = low_price;
//                wave_count++;
//
//                wave[wave_count].price_End = HH_price;
//                wave[wave_count].time_End = HH_time;
//                wave[wave_count].shift_End = HH_shift;
//                wave[wave_count].tf_End = HH_tf;
//
//            }
//        }
//            
//    }
}
            
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool WavesClass::FindPush (int direction,int timeframe,int timeStartToSeek,int timeStartMin,double lengthMin,double retraceRatioMin,int touchDurationKoefMin){
    if (direction == OP_BUY){
        int shiftStartLocal = iBarShift (Symbol(), timeframe, timeStartMin, false); 
        int prev_high = iHigh (Symbol(), timeframe, shiftStartLocal); 
        int prev_time = iTime (Symbol(), timeframe, shiftStartLocal); 
        int prev_shift = shiftStartLocal;
        int prev_duration_2touch = 0;
        int cur_High, cur_Time;
        for (int shiftLocal = shiftStartLocal-1; shiftLocal >= 0; shiftLocal--){
            cur_High = iHigh (Symbol(), timeframe, shiftLocal); 
            cur_Time = iTime (Symbol(), timeframe, shiftLocal); 
            if (cur_High > prev_High
            && cur_Time - prev_Time >= touchDurationKoefMin * prev_2touch_duration){
                // Next 2-touch found
                

            

        }
    }
            
}



        




