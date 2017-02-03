//+------------------------------------------------------------------+
//|                                                      TrendFinder |
//|                                                   Zhinzhich Labs |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Zhinzhich Labs"
#property indicator_chart_window

extern bool alerts_on = true;
extern int timeframe_max = 60;
extern int timeframe_min = 5;
extern int tp_pips_min = 15;
extern int alert_frequency_seconds = 60;
extern bool sms_alerts_on = false;
extern string sms_tel_number = "79516019037";
extern string sms_text = "Alert";

extern string comment2 = "====  Appearance options =====";
extern color wavesLineColor = Gray;
extern int wavesLineWidth = 1;
extern int wavesLineType = STYLE_DASH;
extern color levelLineColor = Gray;
extern int levelLineWidth = 1;
extern int levelLineType = STYLE_DOT;




//---- buffers
double s1[];



// Formations variables

int f_swings_max[7];
double f_price[7][40];
double f_length[7][40];
int f_time[7][40];
int f_shift [7][40];
int f_duration[7][40];
double f_angle[7][40];
double f_duration_avg[7];
double f_length_avg[7];


int f6_depth = 192;
int f5_depth = 96;
int f4_depth = 48;
int f3_depth = 24;
int f2_depth = 12;
int f1_depth = 6;
int deviation= 5;
int backstep = 3;

int f1_swings_max = 40;
int f2_swings_max = 30;
int f3_swings_max = 20;
int f4_swings_max = 20;
int f5_swings_max = 20;
int f6_swings_max = 20;



// Tech variables

color f_color[7];
int f_depth [7];
int tick_count=0;
double lotStep, lotMin, lotMax;
int lotDigits;
double tickValue, stopoutLevel;
int stopoutMode;
double baseLotMult;
double freeMargin;
int spread, spread_max;
double loss_limit;

bool alert_allow;
bool alert;
int alert_last_time;




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

int init()

  {
  
   alert = false;
   alert_last_time = 0;

   // Arrays and variables

   f_swings_max [1] = f1_swings_max;
   f_swings_max [2] = f2_swings_max;
   f_swings_max [3] = f3_swings_max;
   f_swings_max [4] = f4_swings_max;
   f_swings_max [5] = f5_swings_max;
   f_swings_max [6] = f6_swings_max;

   f_depth [1] = f1_depth;
   f_depth [2] = f2_depth;
   f_depth [3] = f3_depth;
   f_depth [4] = f4_depth;
   f_depth [5] = f5_depth;
  
  return(0);
  
  }
   


int deinit ()
   {
   
   clear_objects ();
   
   return (0);
   
   }



  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   alert = false;
   
   if (TimeCurrent () - alert_frequency_seconds >= alert_last_time) 
      {
      alert = true;
      arrays ();
      }
   
   check_draw_patterns ();
	
   return(0);
   
  }
//+------------------------------------------------------------------+









//+------------------------------------------------------------------+
//| FID?01: function initializes swing length and price levels arrays
//+------------------------------------------------------------------+


void arrays ()
  {
   
   int f1_shift1 = 0;
   int f1_shift2 = 0;
   int f2_shift1 = 0;
   int f2_shift2 = 0;
   int f3_shift1 = 0;
   int f3_shift2 = 0;
   int f4_shift1 = 0;
   int f4_shift2 = 0;
   int f5_shift1 = 0;
   int f5_shift2 = 0;
   int f6_shift1 = 0;
   int f6_shift2 = 0;
   
   double f1_price1 = 0;
   double f1_price2 = 0;
   double f2_price1 = 0;
   double f2_price2 = 0;
   double f3_price1 = 0;
   double f3_price2 = 0;
   double f4_price1 = 0;
   double f4_price2 = 0;
   double f5_price1 = 0;
   double f5_price2 = 0;
   double f6_price1 = 0;
   double f6_price2 = 0;

   bool f1_price1_found = false;
   bool f1_price2_found = false;
   bool f2_price1_found = false;
   bool f2_price2_found = false;
   bool f3_price1_found = false;
   bool f3_price2_found = false;
   bool f4_price1_found = false;
   bool f4_price2_found = false;
   bool f5_price1_found = false;
   bool f5_price2_found = false;
   bool f6_price1_found = false;
   bool f6_price2_found = false;
   
   int f1_vertex = 1;
   int f2_vertex = 1;
   int f3_vertex = 1;
   int f4_vertex = 1;
   int f5_vertex = 1;
   int f6_vertex = 1;



   // Initializing swings and price levels arrays
   
   while(!f1_price1_found)
     {
      
      f1_price1=iCustom(Symbol(),timeframe_Main,"zigzag",f1_depth,deviation,backstep,0,f1_shift1);

      if(f1_price1>0)
        {
         f_price [1][f1_vertex -1]= f1_price1;
         f_time [1][f1_vertex -1] = iTime(Symbol(),timeframe_Main,f1_shift1);
         f1_shift2=f1_shift1+1;
         f1_price1_found=true;

         while(f1_vertex<f1_swings_max)
           {

            f1_price2=iCustom(Symbol(),timeframe_Main,"zigzag",f1_depth,deviation,backstep,0,f1_shift2);

            if(f1_price2==0 || f1_price2==f1_price1) f1_shift2++;

            if(f1_price2>0 && f1_price2!=f1_price1)
              {
               f_price [1][f1_vertex]= f1_price2;
               f_time [1][f1_vertex] = iTime(Symbol(),timeframe_Main,f1_shift2);
               f_shift [1][f1_vertex] = f1_shift2;
               f_length[1][f1_vertex-1]=(f1_price1-f1_price2)/Point;
               f_duration [1][f1_vertex-1] = f_time [1][f1_vertex-1] - f_time [1][f1_vertex];
               if (f_duration [1][f1_vertex-1] != 0) f_angle [1][f1_vertex-1] = f_length[1][f1_vertex-1] / f_duration [1][f1_vertex-1];
               f1_shift1=f1_shift2;

               if(f1_vertex>=2)
                 {

                  if(( f_length[1][f1_vertex-2]>0 && f_length[1][f1_vertex-1]>0) || (f_length[1][f1_vertex-2]<0 && f_length[1][f1_vertex-1]<0))
                    {

                     f_length[1][f1_vertex-2]+=f_length[1][f1_vertex-1];
                     f_duration[1][f1_vertex-2]+=f_duration[1][f1_vertex-1];
                     if (f_duration [1][f1_vertex-1] != 0) f_angle [1][f1_vertex-1] = f_length[1][f1_vertex-1] / f_duration [1][f1_vertex-1];
                     f_time[1][f1_vertex-1]=f_time[1][f1_vertex];
                     f_price[1][f1_vertex-1]=f_price[1][f1_vertex];
                     f_shift [1][f1_vertex-1] = f_shift[1][f1_vertex];
                     f1_vertex--;
                    }

                 }

               f1_vertex++;
               f1_price1=f1_price2;
               f1_shift2++;
              }
           }
        }

      f1_shift1++;

     }

   while(!f2_price1_found)
     {

      f2_price1=iCustom(Symbol(),timeframe_Main,"zigzag",f2_depth,deviation,backstep,0,f2_shift1);

      if(f2_price1>0)
        {
         f_price [2][f2_vertex -1]= f2_price1;
         f_time [2][f2_vertex -1] = iTime(Symbol(),timeframe_Main,f2_shift1);
         f2_shift2=f2_shift1+1;
         f2_price1_found=true;

         while(f2_vertex<f2_swings_max)
           {

            f2_price2=iCustom(Symbol(),timeframe_Main,"zigzag",f2_depth,deviation,backstep,0,f2_shift2);

            if(f2_price2==0 || f2_price2==f2_price1) f2_shift2++;

            if(f2_price2>0 && f2_price2!=f2_price1)
              {
               f_price [2][f2_vertex]= f2_price2;
               f_time [2][f2_vertex] = iTime(Symbol(),timeframe_Main,f2_shift2);               
               f_length[2][f2_vertex-1]=(f2_price1-f2_price2)/Point;
               f_shift [2][f2_vertex] = f2_shift2;
               f_duration [2][f2_vertex-1] = f_time [2][f2_vertex-1] - f_time [2][f2_vertex];
               if (f_duration [2][f2_vertex-1] != 0) f_angle [2][f2_vertex-1] = f_length[2][f2_vertex-1] / f_duration [2][f2_vertex-1];
               f2_shift1=f2_shift2;

               if(f2_vertex>=2)
                 {

                  if(( f_length[2][f2_vertex-2]>0 && f_length[2][f2_vertex-1]>0) || (f_length[2][f2_vertex-2]<0 && f_length[2][f2_vertex-1]<0))
                    {

                     f_length[2][f2_vertex-2]+=f_length[2][f2_vertex-1];
                     f_duration[2][f2_vertex-2]+=f_duration[2][f2_vertex-1];
                     if (f_duration [2][f2_vertex-1] != 0) f_angle [2][f2_vertex-1] = f_length[2][f2_vertex-1] / f_duration [2][f2_vertex-1];
                     f_time[2][f2_vertex -1]=f_time[2][f2_vertex];
                     f_price[2][f2_vertex -1]=f_price[2][f2_vertex];
                     f_shift[2][f2_vertex -1]=f_shift[2][f2_vertex];
                     f2_vertex--;
                    }

                 }

               f2_vertex++;
               f2_price1=f2_price2;
               f2_shift2++;
              }
           }
        }

      f2_shift1++;

     }


   while(!f3_price1_found)
     {

      f3_price1=iCustom(Symbol(),timeframe_Main,"zigzag",f3_depth,deviation,backstep,0,f3_shift1);
      
      if(f3_shift1>f3_depth*12) break;

      if(f3_price1>0)
        {
         f_price [3][f3_vertex -1]= f3_price1;
         f_time [3][f3_vertex -1] = iTime(Symbol(),timeframe_Main,f3_shift1);
         f3_shift2=f3_shift1+1;
         f3_price1_found=true;

         while(f3_vertex<f3_swings_max)
           {

            f3_price2=iCustom(Symbol(),timeframe_Main,"zigzag",f3_depth,deviation,backstep,0,f3_shift2);

            if(f3_price2==0 || f3_price2==f3_price1) f3_shift2++;
            if((f3_shift2-f3_shift1)>f3_depth*12) break;

            if(f3_price2>0 && f3_price2!=f3_price1)
              {
               f_price [3][f3_vertex]= f3_price2;
               f_time [3][f3_vertex] = iTime(Symbol(),timeframe_Main,f3_shift2);
               f_length[3][f3_vertex-1]=(f3_price1-f3_price2)/Point;
               f_shift[3][f3_vertex -1]=f3_shift2;
               f_duration [3][f3_vertex-1] = f_time [3][f3_vertex-1] - f_time [3][f3_vertex];
               if (f_duration [3][f3_vertex-1] != 0) f_angle [3][f3_vertex-1] = f_length[3][f3_vertex-1] / f_duration [3][f3_vertex-1];
               f3_shift1=f3_shift2;

               if(f3_vertex>=2)
                 {

                  if(( f_length[3][f3_vertex-2]>0 && f_length[3][f3_vertex-1]>0) || (f_length[3][f3_vertex-2]<0 && f_length[3][f3_vertex-1]<0))
                    {

                     f_length[3][f3_vertex-2]+=f_length[3][f3_vertex-1];
                     f_duration[3][f3_vertex-2]+=f_duration [3][f3_vertex-1];
                     if (f_duration [3][f3_vertex-1] != 0) f_angle [3][f3_vertex-1] = f_length[3][f3_vertex-1] / f_duration [3][f3_vertex-1];
                     f_time[3][f3_vertex -1]=f_time[3][f3_vertex];
                     f_price[3][f3_vertex -1]=f_price[3][f3_vertex];
                     f_shift[3][f3_vertex -1]=f_shift[3][f3_vertex];
                     f3_vertex--;
                    }

                 }

               f3_vertex++;
               f3_price1=f3_price2;
               f3_shift2++;
              }
           }
        }

      f3_shift1++;

     }

   while(!f4_price1_found)
     {

      f4_price1=iCustom(Symbol(),timeframe_Main,"zigzag",f4_depth,deviation,backstep,0,f4_shift1);

      if(f4_shift1>f4_depth*12) break;

      if(f4_price1>0)
        {
         f_price [4][f4_vertex -1]= f4_price1;
         f_time [4][f4_vertex -1] = iTime(Symbol(),timeframe_Main,f4_shift1);
         f4_shift2=f4_shift1+1;
         f4_price1_found=true;

         while(f4_vertex<f4_swings_max)
           {

            f4_price2=iCustom(Symbol(),timeframe_Main,"zigzag",f4_depth,deviation,backstep,0,f4_shift2);

            if(f4_price2==0 || f4_price2==f4_price1) f4_shift2++;
            if((f4_shift2-f4_shift1)>f4_depth*12) break;

            if(f4_price2>0 && f4_price2!=f4_price1)
              {
               f_price [4][f4_vertex]= f4_price2;
               f_time [4][f4_vertex] = iTime(Symbol(),timeframe_Main,f4_shift2);
               f_length[4][f4_vertex-1]=(f4_price1-f4_price2)/Point;
               f_shift[4][f4_vertex-1]=f4_shift2;
               f_duration [4][f4_vertex-1] = f_time [4][f4_vertex-1] - f_time [4][f4_vertex];
               if (f_duration [4][f4_vertex-1] != 0) f_angle [4][f4_vertex-1] = f_length[4][f4_vertex-1] / f_duration [4][f4_vertex-1];
               f4_shift1=f4_shift2;

               if(f4_vertex>=2)
                 {

                  if(( f_length[4][f4_vertex-2]>0 && f_length[4][f4_vertex-1]>0) || (f_length[4][f4_vertex-2]<0 && f_length[4][f4_vertex-1]<0))
                    {

                     f_length[4][f4_vertex-2]+=f_length[4][f4_vertex-1];
                     f_duration[4][f4_vertex-2]+=f_duration[4][f4_vertex-1];
                     if (f_duration [4][f4_vertex-1] != 0) f_angle [4][f4_vertex-1] = f_length[4][f4_vertex-1] / f_duration [4][f4_vertex-1];
                     f_time[4][f4_vertex -1]=f_time[4][f4_vertex];
                     f_price[4][f4_vertex -1]=f_price[4][f4_vertex];
                     f_shift[4][f4_vertex -1]=f_shift[4][f4_vertex];
                     f4_vertex--;
                    }

                 }

               f4_vertex++;
               f4_price1=f4_price2;
               f4_shift2++;
              }
           }
        }

      f4_shift1++;

     }



   while(!f5_price1_found)
     {

      f5_price1=iCustom(Symbol(),timeframe_Main,"zigzag",f5_depth,deviation,backstep,0,f5_shift1);

      if(f5_shift1>f5_depth*12) break;

      if(f5_price1>0)
        {
         f_price [5][f5_vertex -1]= f5_price1;
         f_time [5][f5_vertex -1] = iTime(Symbol(),timeframe_Main,f5_shift1);
         f5_shift2=f5_shift1+1;
         f5_price1_found=true;

         while(f5_vertex<f5_swings_max)
           {

            f5_price2=iCustom(Symbol(),timeframe_Main,"zigzag",f5_depth,deviation,backstep,0,f5_shift2);

            if(f5_price2==0 || f5_price2==f5_price1) f5_shift2++;
            if((f5_shift2-f5_shift1)>f5_depth*12) break;

            if(f5_price2>0 && f5_price2!=f5_price1)
              {
               f_price [5][f5_vertex]= f5_price2;
               f_time [5][f5_vertex] = iTime(Symbol(),timeframe_Main,f5_shift2);
               f_length[5][f5_vertex-1]=(f5_price1-f5_price2)/Point;
               f_shift[5][f5_vertex-1]=f5_shift2;
               f_duration [5][f5_vertex-1] = f_time [5][f5_vertex-1] - f_time [5][f5_vertex];
               if (f_duration [5][f5_vertex-1] != 0) f_angle [5][f5_vertex-1] = f_length[5][f5_vertex-1] / f_duration [5][f5_vertex-1];
               f5_shift1=f5_shift2;

               if(f5_vertex>=2)
                 {

                  if(( f_length[5][f5_vertex-2]>0 && f_length[5][f5_vertex-1]>0) || (f_length[5][f5_vertex-2]<0 && f_length[5][f5_vertex-1]<0))
                    {

                     f_length[5][f5_vertex-2]+=f_length[5][f5_vertex-1];
                     f_duration[5][f5_vertex-2]+=f_duration[5][f5_vertex-1];
                     if (f_duration [5][f5_vertex-1] != 0) f_angle [5][f5_vertex-1] = f_length[5][f5_vertex-1] / f_duration [5][f5_vertex-1];
                     f_time[5][f5_vertex -1]=f_time[5][f5_vertex];
                     f_price[5][f5_vertex -1]=f_price[5][f5_vertex];
                     f_shift[5][f5_vertex -1]=f_shift[5][f5_vertex];
                     f5_vertex--;
                    }

                 }

               f5_vertex++;
               f5_price1=f5_price2;
               f5_shift2++;
              }
           }
        }

      f5_shift1++;

     }
  
     while(!f6_price1_found)
     {

      f6_price1=iCustom(Symbol(),timeframe_Main,"zigzag",f6_depth,deviation,backstep,0,f6_shift1);

      if(f6_shift1>f6_depth*12) break;

      if(f6_price1>0)
        {
         f_price [6][f6_vertex -1]= f6_price1;
         f_time [6][f6_vertex -1] = iTime(Symbol(),timeframe_Main,f6_shift1);
         f6_shift2=f6_shift1+1;
         f6_price1_found=true;

         while(f6_vertex<f6_swings_max)
           {

            f6_price2=iCustom(Symbol(),timeframe_Main,"zigzag",f6_depth,deviation,backstep,0,f6_shift2);

            if(f6_price2==0 || f6_price2==f6_price1) f6_shift2++;
            if((f6_shift2-f6_shift1)>f6_depth*12) break;

            if(f6_price2>0 && f6_price2!=f6_price1)
              {
               f_price [6][f6_vertex]= f6_price2;
               f_time [6][f6_vertex] = iTime(Symbol(),timeframe_Main,f6_shift2);
               f_length[6][f6_vertex-1]=(f6_price1-f6_price2)/Point;
               f_shift[6][f6_vertex-1]=f6_shift2;
               f_duration [6][f6_vertex-1] = f_time [6][f6_vertex-1] - f_time [6][f6_vertex];
               if (f_duration [6][f6_vertex-1] != 0) f_angle [6][f6_vertex-1] = f_length[6][f6_vertex-1] / f_duration [6][f6_vertex-1];
               f6_shift1=f6_shift2;

               if(f6_vertex>=2)
                 {

                  if(( f_length[6][f6_vertex-2]>0 && f_length[6][f6_vertex-1]>0) || (f_length[6][f6_vertex-2]<0 && f_length[6][f6_vertex-1]<0))
                    {

                     f_length[6][f6_vertex-2]+=f_length[6][f6_vertex-1];
                     f_duration[6][f6_vertex-2]+=f_duration[6][f6_vertex-1];
                     if (f_duration [6][f6_vertex-1] != 0) f_angle [6][f6_vertex-1] = f_length[6][f6_vertex-1] / f_duration [6][f6_vertex-1];
                     f_time[6][f6_vertex -1]=f_time[6][f6_vertex];
                     f_price[6][f6_vertex -1]=f_price[6][f6_vertex];
                     f_shift[6][f6_vertex -1]=f_shift[6][f6_vertex];
                     f6_vertex--;
                    }

                 }

               f6_vertex++;
               f6_price1=f6_price2;
               f6_shift2++;
              }
           }
        }

      f6_shift1++;

     }

  

  }
  
  
  
  
  

//+-------------------------------------------------------------------------+
// FID?02: function calculates average lengths of swings using extrenal parameters
//+-------------------------------------------------------------------------+

void averages ()
  {

   double total_length_local [7];
   int total_duration_local [7];
   double avg_number [7];
   int waves_count_local [7];
   

   for(int t=1; t<=5; t++)
     {
     total_length_local[t]=0;
     total_duration_local [t] = 0;
     }

   for(int f=1; f<=5; f++)
     {
      
      for(t = 1; t <= f_swings_max[f]; t++)
        {
         if(f_length [f][t] ==0) break;
         waves_count_local [f]++;
         total_length_local [f] += MathAbs(f_length[f][t]);
         total_duration_local [f] += f_duration [f][t];
        }

      // Вычисляем среднюю длину и продолжительность волны формации
      
      if(waves_count_local[f]!=0) 
         {
         f_length_avg [f] = NormalizeDouble (total_length_local [f] / waves_count_local [f],0);
         f_duration_avg [f] = NormalizeDouble (total_duration_local [f] / waves_count_local [f],0);
         }
      
     }
  
  
  }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void check_draw_patterns ()
   {
   
   if (pattern_OU && alert)
      {
      
      clear_objects ();
      
      alert_last_time = TimeCurrent ();
      
      for (int f = 5; f >= 2; f--)
         {
         
         // BUY SIGNALS
         
         if (f_length [f][0] < 0
            && f_length [f-1][0] < 0
            && f_time [f-1][3] >= f_time [f][1]
            && MathAbs (f_angle [f][0]) < MathAbs (f_angle [f][2])
            && MathAbs (f_angle [f][1]) > MathAbs (f_angle [f][3])
            && MathAbs (f_angle [f][2]) > MathAbs (f_angle [f][4])
            && MathAbs (f_length [f][1]) > MathAbs (f_length [f][3])
            && MathAbs (f_length [f][1]) >= f_length_avg [f]
            && MathAbs (f_length [f][2]) >= 0.77 * f_length_avg [f]
            && MathAbs (f_length [f][3]) >= 0.77 * f_length_avg [f]
            && MathAbs (f_length [f][1]) >= 2 * MathAbs (f_length [f][2])
            && f_duration [f][0] >= f_duration [f][1])
            
               {
               
               Alert (Symbol(),", M"+timeframe_Main+": BUY OU PATTERN DETECTED");
               
               string name;
               
               name = StringConcatenate ("Q10_line_buy_OU_w0");
               ObjectCreate(name,OBJ_TREND,0,f_time [f][3],f_price [f][3],f_time [f][2],f_price [f][2]);
               ObjectSet (name,OBJPROP_COLOR,wavesLineColor);
               ObjectSet (name,OBJPROP_WIDTH,wavesLineWidth);
               ObjectSet (name,OBJPROP_TYPE,wavesLineType);
               ObjectSet (name,OBJPROP_RAY,false);
               
               name = StringConcatenate ("Q10_line_buy_OU_w1");
               ObjectCreate(name,OBJ_TREND,0,f_time [f][2],f_price [f][2],f_time [f][1],f_price [f][1]);
               ObjectSet (name,OBJPROP_COLOR,wavesLineColor);
               ObjectSet (name,OBJPROP_WIDTH,wavesLineWidth);
               ObjectSet (name,OBJPROP_TYPE,wavesLineType);
               ObjectSet (name,OBJPROP_RAY,false);
               
               name = StringConcatenate ("Q10_line_buy_OU_w2");
               ObjectCreate(name,OBJ_TREND,0,f_time [f][1],f_price [f][1],f_time [f][0],f_price [f][0]);
               ObjectSet (name,OBJPROP_COLOR,wavesLineColor);
               ObjectSet (name,OBJPROP_WIDTH,wavesLineWidth);
               ObjectSet (name,OBJPROP_TYPE,wavesLineType);
               ObjectSet (name,OBJPROP_RAY,false);
               
               name = StringConcatenate ("Q10_line_buy_OU_level");
               ObjectCreate(name,OBJ_TREND,0,f_time [f][3],f_price [f][3],f_time [f][0],f_price [f][3]);
               ObjectSet (name,OBJPROP_COLOR,levelLineColor);
               ObjectSet (name,OBJPROP_WIDTH,levelLineWidth);
               ObjectSet (name,OBJPROP_TYPE,levelLineType);
               ObjectSet (name,OBJPROP_RAY,false);
               
               }
            
            
         // SELL SIGNALS
         
         if (f_length [f][0] > 0
            && f_length [f-1][0] > 0
            && f_time [f-1][3] >= f_time [f][1]
            && MathAbs (f_angle [f][0]) < MathAbs (f_angle [f][2])
            && MathAbs (f_angle [f][1]) > MathAbs (f_angle [f][3])
            && MathAbs (f_angle [f][2]) > MathAbs (f_angle [f][4])
            && MathAbs (f_length [f][1]) > MathAbs (f_length [f][3])
            && MathAbs (f_length [f][1]) >= f_length_avg [f]
            && MathAbs (f_length [f][2]) >= 0.77 * f_length_avg [f]
            && MathAbs (f_length [f][3]) >= 0.77 * f_length_avg [f]
            && MathAbs (f_length [f][1]) >= 2 * MathAbs (f_length [f][2])
            && f_duration [f][0] >= f_duration [f][1])
            
               {
               
               Alert (Symbol(),", M"+timeframe_Main+": SELL OU PATTERN DETECTED");
               
               name = StringConcatenate ("Q10_line_sell_OU_w0");
               ObjectCreate(name,OBJ_TREND,0,f_time [f][3],f_price [f][3],f_time [f][2],f_price [f][2]);
               ObjectSet (name,OBJPROP_COLOR,wavesLineColor);
               ObjectSet (name,OBJPROP_WIDTH,wavesLineWidth);
               ObjectSet (name,OBJPROP_TYPE,wavesLineType);
               ObjectSet (name,OBJPROP_RAY,false);
               
               name = StringConcatenate ("Q10_line_sell_OU_w1");
               ObjectCreate(name,OBJ_TREND,0,f_time [f][2],f_price [f][2],f_time [f][1],f_price [f][1]);
               ObjectSet (name,OBJPROP_COLOR,wavesLineColor);
               ObjectSet (name,OBJPROP_WIDTH,wavesLineWidth);
               ObjectSet (name,OBJPROP_TYPE,wavesLineType);
               ObjectSet (name,OBJPROP_RAY,false);
               
               name = StringConcatenate ("Q10_line_sell_OU_w2");
               ObjectCreate(name,OBJ_TREND,0,f_time [f][1],f_price [f][1],f_time [f][0],f_price [f][0]);
               ObjectSet (name,OBJPROP_COLOR,wavesLineColor);
               ObjectSet (name,OBJPROP_WIDTH,wavesLineWidth);
               ObjectSet (name,OBJPROP_TYPE,wavesLineType);
               ObjectSet (name,OBJPROP_RAY,false);
               
               name = StringConcatenate ("Q10_line_sell_OU_level");
               ObjectCreate(name,OBJ_TREND,0,f_time [f][3],f_price [f][3],f_time [f][0],f_price [f][3]);
               ObjectSet (name,OBJPROP_COLOR,levelLineColor);
               ObjectSet (name,OBJPROP_WIDTH,levelLineWidth);
               ObjectSet (name,OBJPROP_TYPE,levelLineType);
               ObjectSet (name,OBJPROP_RAY,false);
               
               }
         
         
         }
      
      }
   
   
   }
   




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void clear_objects ()
   {
   
   for(int tLocal=ObjectsTotal(); tLocal>=0; tLocal--)
     {
     if(StringSubstr(ObjectName(tLocal),0,3)=="Q10") ObjectDelete(ObjectName(tLocal));
     }
   
   }
   

