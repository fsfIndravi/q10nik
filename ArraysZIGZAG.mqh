//+------------------------------------------------------------------+
//|                                                 arraysZIGZAG.mqh |
//|                                                   Zhinzhich Labs |
//|                                                                  |
//+------------------------------------------------------------------+

int f6_depth = 192;
int f5_depth = 96;
int f4_depth = 48;
int f3_depth = 24;
int f2_depth = 12;
int f1_depth = 4;
int deviation= 5;
int backstep = 3;

int f1_swings_max = 7;
int f2_swings_max = 7;
int f3_swings_max = 12;
int f4_swings_max = 32;
int f5_swings_max = 32;
int f6_swings_max = 12;

int f_swings_max [7];
double f_price [7][40];
double f_length [7][40];
int f_time [7][40];
int f_shift [7][40];
int f_duration [7][40];
double f_angle [7][40];
double f_duration_avg [7];
double f_length_avg [7];
int f_wave_buy [7], f_wave_sell [7];
int f_last_time [7];

// F1 Impulse variables

double f1_impulse_price [6];
double f1_impulse_length [6];
int f1_impulse_time [6];
int f1_impulse_shift [6];
int f1_impulse_duration [6];
double f1_impulse_angle [6];

color f_color[7];
int f_depth [7];

// Outside Swings

double outsideSwing_Buy_Angle [7], outsideSwing_Sell_Angle [7];
double outsideSwing_Buy_Length [7], outsideSwing_Sell_Length [7];
int outsideSwing_Buy_Duration [7], outsideSwing_Sell_Duration [7];
double outsideSwing_Buy_Shift [7], outsideSwing_Sell_Shift [7];
double outsideSwing_Buy_PB_angle [7], outsideSwing_Sell_PB_angle [7];
double outsideSwing_Buy_PB_angle_max [7], outsideSwing_Sell_PB_angle_max [7];
double outsideSwing_Buy_PB_ratio [7], outsideSwing_Sell_PB_ratio [7];
double outsideSwing_Buy_PB_ratio_max [7], outsideSwing_Sell_PB_ratio_max [7];
double outsideSwing_Buy_PB_length [7], outsideSwing_Sell_PB_length [7];
double outsideSwing_Buy_PB_length_max [7], outsideSwing_Sell_PB_length_max [7];
int outsideSwing_Buy_PB_duration [7], outsideSwing_Sell_PB_duration [7];
int outsideSwing_Buy_PB_WC [7], outsideSwing_Sell_PB_WC [7];
double outsideSwing_Buy_PriceStart [7], outsideSwing_Sell_PriceStart [7];
double outsideSwing_Buy_PriceGoal [7], outsideSwing_Sell_PriceGoal [7];
double outsideSwing_Buy_PriceCorrection_0660 [7], outsideSwing_Sell_PriceCorrection_0660 [7];
double outsideSwing_Buy_PriceCorrector [7], outsideSwing_Sell_PriceCorrector [7];
double outsideSwing_Buy_PriceCheck [7], outsideSwing_Sell_PriceCheck [7];
double outsideSwing_Buy_PriceControl [7], outsideSwing_Sell_PriceControl [7];
int outsideSwing_Sell_TimeStart [7], outsideSwing_Sell_TimeEnd [7];
int outsideSwing_Buy_TimeStart [7], outsideSwing_Buy_TimeEnd [7];
double outsideSwing_Buy_PriceEnd [7], outsideSwing_Sell_PriceEnd [7];





//+------------------------------------------------------------------+
//| FID?01: function initializes swing length and price levels arrays
//+------------------------------------------------------------------+


void arrays (int timeframe_Local, int fNumberLocal)
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
   
   int f1_vertex = 0;
   int f2_vertex = 1;
   int f3_vertex = 1;
   int f4_vertex = 1;
   int f5_vertex = 1;
   int f6_vertex = 1;



   // Initializing swings and price levels arrays
   
   if (fNumberLocal == 1)
      {
      while(!f1_price1_found)
        {
         
         f1_price1=iCustom(Symbol(),timeframe_Local,"zigzag",f1_depth,deviation,backstep,0,f1_shift1);
   
         if(f1_price1 > 0)
            {
            f_price [1][f1_vertex] = f1_price1;
            f_time [1][f1_vertex] = iTime(Symbol(),timeframe_Local,f1_shift1);
            f1_shift2 = f1_shift1 + 1;
            f1_price1_found=true;
   
            while(f1_vertex < f1_swings_max)
              {
   
               f1_price2 = iCustom(Symbol(),timeframe_Local,"zigzag",f1_depth,deviation,backstep,0,f1_shift2);
   
               if(f1_price2==0 || f1_price2==f1_price1) f1_shift2++;
   
               if(f1_price2>0 && f1_price2!=f1_price1)
                 {
                  
                  f1_vertex++;
                  
                  if (f1_vertex == 2 && iTime(Symbol(),timeframe_Local,f1_shift2) == f_time [1][f1_vertex]) break; // ¬рем€ вершины 1 не изменилось, значит дальше можно не продолжать
                  
                  f_price [1][f1_vertex]= f1_price2;
                  f_time [1][f1_vertex] = iTime(Symbol(),timeframe_Local,f1_shift2);                  
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
   
                  f1_price1=f1_price2;
                  f1_shift2++;
                 }
              }
           }
   
         f1_shift1++;
   
        }
   }
   
   
   if (fNumberLocal == 2)
      {
   
   while(!f2_price1_found)
     {

      f2_price1=iCustom(Symbol(),timeframe_Local,"zigzag",f2_depth,deviation,backstep,0,f2_shift1);

      if(f2_price1>0)
        {
         f_price [2][f2_vertex-1]= f2_price1;
         f_time [2][f2_vertex-1] = iTime(Symbol(),timeframe_Local,f2_shift1);
         f2_shift2=f2_shift1+1;
         f2_price1_found=true;

         while(f2_vertex<f2_swings_max)
           {

            f2_price2=iCustom(Symbol(),timeframe_Local,"zigzag",f2_depth,deviation,backstep,0,f2_shift2);

            if(f2_price2==0 || f2_price2==f2_price1) f2_shift2++;

            if(f2_price2>0 && f2_price2!=f2_price1)
              {
               if (f2_vertex == 2 && iTime(Symbol(),timeframe_Local,f2_shift2) == f_time [2][f2_vertex]) break; // ¬рем€ вершины 1 не изменилось, значит дальше можно не продолжать
               f_price [2][f2_vertex]= f2_price2;
               f_time [2][f2_vertex] = iTime(Symbol(),timeframe_Local,f2_shift2);               
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
   }
   
   if (fNumberLocal == 3)
      {

   while(!f3_price1_found)
     {

      f3_price1=iCustom(Symbol(),timeframe_Local,"zigzag",f3_depth,deviation,backstep,0,f3_shift1);
      
      if(f3_shift1>f3_depth*12) break;

      if(f3_price1>0)
        {
         f_price [3][f3_vertex -1]= f3_price1;
         f_time [3][f3_vertex -1] = iTime(Symbol(),timeframe_Local,f3_shift1);
         f3_shift2=f3_shift1+1;
         f3_price1_found=true;

         while(f3_vertex<f3_swings_max)
           {

            f3_price2=iCustom(Symbol(),timeframe_Local,"zigzag",f3_depth,deviation,backstep,0,f3_shift2);

            if(f3_price2==0 || f3_price2==f3_price1) f3_shift2++;
            if((f3_shift2-f3_shift1)>f3_depth*12) break;

            if(f3_price2>0 && f3_price2!=f3_price1)
              {
               if (f3_vertex == 2 && iTime(Symbol(),timeframe_Local,f3_shift2) == f_time [3][f3_vertex]) break; // ¬рем€ вершины 1 не изменилось, значит дальше можно не продолжать
               f_price [3][f3_vertex]= f3_price2;
               f_time [3][f3_vertex] = iTime(Symbol(),timeframe_Local,f3_shift2);
               //if (f_time [3][f3_vertex-1] < timeLimit && timeLimit > 0 && f3_vertex > 0) break;
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
   }
   
   
   if (fNumberLocal == 4)
      {
   while(!f4_price1_found)
     {

      f4_price1=iCustom(Symbol(),timeframe_Local,"zigzag",f4_depth,deviation,backstep,0,f4_shift1);

      if(f4_shift1>f4_depth*12) break;

      if(f4_price1>0)
        {
         f_price [4][f4_vertex -1]= f4_price1;
         f_time [4][f4_vertex -1] = iTime(Symbol(),timeframe_Local,f4_shift1);
         f4_shift2=f4_shift1+1;
         f4_price1_found=true;

         while(f4_vertex<f4_swings_max)
           {

            f4_price2=iCustom(Symbol(),timeframe_Local,"zigzag",f4_depth,deviation,backstep,0,f4_shift2);

            if(f4_price2==0 || f4_price2==f4_price1) f4_shift2++;
            if((f4_shift2-f4_shift1)>f4_depth*12) break;

            if(f4_price2>0 && f4_price2!=f4_price1)
              {
               if (f4_vertex == 2 && iTime(Symbol(),timeframe_Local,f4_shift2) == f_time [4][f4_vertex]) break; // ¬рем€ вершины 1 не изменилось, значит дальше можно не продолжать
               f_price [4][f4_vertex]= f4_price2;
               f_time [4][f4_vertex] = iTime(Symbol(),timeframe_Local,f4_shift2);
               //if (f_time [4][f4_vertex-1] < timeLimit && timeLimit > 0 && f4_vertex > 0) break;
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
   }


   if (fNumberLocal == 5)
      {

   while(!f5_price1_found)
     {

      f5_price1=iCustom(Symbol(),timeframe_Local,"zigzag",f5_depth,deviation,backstep,0,f5_shift1);

      if(f5_shift1>f5_depth*12) break;

      if(f5_price1>0)
        {
         f_price [5][f5_vertex -1]= f5_price1;
         f_time [5][f5_vertex -1] = iTime(Symbol(),timeframe_Local,f5_shift1);
         f5_shift2=f5_shift1+1;
         f5_price1_found=true;

         while(f5_vertex<f5_swings_max)
           {

            f5_price2=iCustom(Symbol(),timeframe_Local,"zigzag",f5_depth,deviation,backstep,0,f5_shift2);

            if(f5_price2==0 || f5_price2==f5_price1) f5_shift2++;
            if((f5_shift2-f5_shift1)>f5_depth*12) break;

            if(f5_price2>0 && f5_price2!=f5_price1)
              {
               if (f5_vertex == 2 && iTime(Symbol(),timeframe_Local,f5_shift2) == f_time [5][f5_vertex]) break; // ¬рем€ вершины 1 не изменилось, значит дальше можно не продолжать
               f_price [5][f5_vertex]= f5_price2;
               f_time [5][f5_vertex] = iTime(Symbol(),timeframe_Local,f5_shift2);
               //if (f_time [5][f5_vertex-1] < timeLimit && timeLimit > 0 && f5_vertex > 0) break;
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
  }
  
  
  if (fNumberLocal == 6)
      {
     while(!f6_price1_found)
     {

      f6_price1=iCustom(Symbol(),timeframe_Local,"zigzag",f6_depth,deviation,backstep,0,f6_shift1);

      if(f6_shift1>f6_depth*12) break;

      if(f6_price1>0)
        {
         f_price [6][f6_vertex -1]= f6_price1;
         f_time [6][f6_vertex -1] = iTime(Symbol(),timeframe_Local,f6_shift1);
         f6_shift2=f6_shift1+1;
         f6_price1_found=true;

         while(f6_vertex<f6_swings_max)
           {

            f6_price2=iCustom(Symbol(),timeframe_Local,"zigzag",f6_depth,deviation,backstep,0,f6_shift2);

            if(f6_price2==0 || f6_price2==f6_price1) f6_shift2++;
            if((f6_shift2-f6_shift1)>f6_depth*12) break;

            if(f6_price2>0 && f6_price2!=f6_price1)
              {
               if (f6_vertex == 2 && iTime(Symbol(),timeframe_Local,f6_shift2) == f_time [6][f6_vertex]) break; // ¬рем€ вершины 1 не изменилось, значит дальше можно не продолжать
               f_price [6][f6_vertex]= f6_price2;
               f_time [6][f6_vertex] = iTime(Symbol(),timeframe_Local,f6_shift2);
               //if (f_time [6][f6_vertex-1] < timeLimit && timeLimit > 0 && f6_vertex > 0) break;
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

      // ¬ычисл€ем среднюю длину и продолжительность волны формации
      
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


void draw_f_number (string fNumberLocal, int directionLocal, double priceLocal, int timeLocal, int orderTicketLocal)
   {
   
   string objName, objArrowName;
   color colorLocal;
   string objText;
   color colorArrowLocal;
   int typeArrow;
   
   objText = fNumberLocal;
   
   if (directionLocal > 0) 
      {
      objName = StringConcatenate ("OrderLabel_",orderTicketLocal);
      objArrowName = StringConcatenate ("OrderArrow_",orderTicketLocal);
      colorLocal = DodgerBlue;
      colorArrowLocal = Blue;
      typeArrow = 2;
      }
   if (directionLocal < 0) 
      {
      objName = StringConcatenate ("OrderLabel_",orderTicketLocal);
      objArrowName = StringConcatenate ("OrderArrow_",orderTicketLocal);
      colorLocal = Red;
      colorArrowLocal = Red;
      typeArrow = 2;
      }
   
   if (ObjectFind (objName) != 0)
      {
      ObjectCreate (objName,OBJ_TEXT,0,timeLocal,priceLocal);
      ObjectSetText(objName,objText,20,"Arial",colorLocal);
      
      ObjectCreate(objArrowName, OBJ_ARROW, 0, timeLocal, priceLocal);
      ObjectSet(objArrowName, OBJPROP_ARROWCODE, typeArrow); 
      ObjectSet(objArrowName, OBJPROP_COLOR, colorArrowLocal);
      
      }
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void delete_f_number (int fNumberLocal, int directionLocal)
   {
   
   string objName;
   
   
   if (directionLocal > 0) objName = StringConcatenate ("Label F",fNumberLocal," BUY");
   if (directionLocal < 0) objName = StringConcatenate ("Label F",fNumberLocal," SELL");
   
   }
   





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void outsideSwings (int timeframe_Local)
   {
   
   // ќбнуление переменных
   
   for (int f = 1; f <=5; f++)
      {
      
      outsideSwing_Buy_Length [f] = 0;
      outsideSwing_Buy_Duration [f] = 0;
      outsideSwing_Buy_Angle [f] = 0;
      outsideSwing_Buy_Shift [f] = 0;
      outsideSwing_Buy_PB_WC [f] = 0;
      outsideSwing_Buy_PriceStart [f] = 0;
      outsideSwing_Buy_PriceEnd [f] = 0;
      outsideSwing_Buy_TimeStart [f] = 0;
      outsideSwing_Buy_TimeEnd [f] = 0;
      outsideSwing_Buy_PB_length [f] = 0;
      outsideSwing_Buy_PB_length_max [f] = 0;
      outsideSwing_Buy_PB_duration [f] = 0;
      outsideSwing_Buy_PB_ratio [f] = 0;
      outsideSwing_Buy_PB_ratio_max [f] = 0;
      outsideSwing_Buy_PB_angle [f] = 0;
      
      outsideSwing_Sell_Length [f] = 0;
      outsideSwing_Sell_Duration [f] = 0;
      outsideSwing_Sell_Angle [f] = 0;
      outsideSwing_Sell_Shift [f] = 0;
      outsideSwing_Sell_PB_WC [f] = 0;
      outsideSwing_Sell_PriceStart [f] = 0;
      outsideSwing_Sell_PriceEnd [f] = 0;
      outsideSwing_Sell_TimeStart [f] = 0;
      outsideSwing_Sell_TimeEnd [f] = 0;
      outsideSwing_Sell_PB_length [f] = 0;
      outsideSwing_Sell_PB_length_max [f] = 0;
      outsideSwing_Sell_PB_duration [f] = 0;
      outsideSwing_Sell_PB_ratio [f] = 0;
      outsideSwing_Sell_PB_ratio_max [f] = 0;
      outsideSwing_Sell_PB_angle [f] = 0;
      
      }
   
   for (f = 1; f <= 5; f++)
      {
      
      for (int shiftLocal = 1; shiftLocal < f_swings_max [f]; shiftLocal ++)
         {
         
         if (f_length [f][shiftLocal] > 0
            && iLow (Symbol (),timeframe_Local,iLowest (Symbol(),timeframe_Local,MODE_LOW,iBarShift (Symbol(),timeframe_Local,f_time [f][shiftLocal],false),0)) >= f_price [f][shiftLocal+1]
            && iHigh (Symbol (),timeframe_Local,iHighest (Symbol(),timeframe_Local,MODE_HIGH,iBarShift (Symbol(),timeframe_Local,f_time [f][shiftLocal],false),0)) <= f_price [f][shiftLocal])
            
               {
               
               outsideSwing_Buy_Length [f] = f_length [f][shiftLocal];
               outsideSwing_Buy_Duration [f] = f_duration [f][shiftLocal];
               outsideSwing_Buy_Angle [f] = NormalizeDouble (f_angle [f][shiftLocal],3);
               outsideSwing_Buy_Shift [f] = shiftLocal;
               outsideSwing_Buy_PB_WC [f] = shiftLocal;
               outsideSwing_Buy_PriceStart [f] = f_price [f][shiftLocal+1];
               outsideSwing_Buy_PriceEnd [f] = f_price [f][shiftLocal];
               outsideSwing_Buy_TimeStart [f] = f_time [f][shiftLocal+1];
               outsideSwing_Buy_TimeEnd [f] = f_time [f][shiftLocal];
               outsideSwing_Buy_PriceCorrection_0660 [f] = f_price [f][shiftLocal] - 0.66 * MathAbs (outsideSwing_Buy_Length [f]) * Point;
               outsideSwing_Buy_PriceCorrector [f] = f_price [f][shiftLocal+2];
               outsideSwing_Buy_PriceCheck [f] = 0.5 * (outsideSwing_Buy_PriceCorrection_0660 [f] + outsideSwing_Buy_PriceCorrector [f]);
               outsideSwing_Buy_PriceControl [f] = f_price [f][shiftLocal] - 0.34 * MathAbs (outsideSwing_Buy_Length [f]) * Point;
               outsideSwing_Buy_PB_length [f] = (f_price [f][0] - f_price [f][shiftLocal]) / Point;
               outsideSwing_Buy_PB_length_max [f] = (iLow (Symbol (),timeframe_Local,iLowest (Symbol(),timeframe_Local,MODE_LOW,iBarShift (Symbol(),timeframe_Local,f_time [f][shiftLocal],false),0)) >= f_price [f][shiftLocal+1] - f_price [f][shiftLocal]) / Point;
               outsideSwing_Buy_PB_duration [f] = TimeCurrent () - f_time [f][shiftLocal];
               if (f_length [f][0] < 0) outsideSwing_Buy_PriceGoal [f] = f_price [f][0] + MathAbs (outsideSwing_Buy_Length [f]) * Point;
               if (f_length [f][0] > 0) outsideSwing_Buy_PriceGoal [f] = f_price [f][1] + MathAbs (outsideSwing_Buy_Length [f]) * Point;
               if (outsideSwing_Buy_Length [f] != 0) outsideSwing_Buy_PB_ratio [f] = NormalizeDouble (MathAbs (outsideSwing_Buy_PB_length [f] / outsideSwing_Buy_Length [f]),2);
               if (outsideSwing_Buy_Length [f] != 0) outsideSwing_Buy_PB_ratio_max [f] = NormalizeDouble (MathAbs (outsideSwing_Buy_PB_length_max [f] / outsideSwing_Buy_Length [f]),2);
               if (outsideSwing_Buy_PB_duration [f] != 0) outsideSwing_Buy_PB_angle [f] = NormalizeDouble (outsideSwing_Buy_PB_length [f] / outsideSwing_Buy_PB_duration [f],2);
               if (outsideSwing_Buy_PB_duration [f] != 0) outsideSwing_Buy_PB_angle_max [f] = NormalizeDouble (outsideSwing_Buy_PB_length_max [f] / outsideSwing_Buy_PB_duration [f],2);
               
               }
         
         
         
         
         if (f_length [f][shiftLocal] < 0
            && iLow (Symbol (),timeframe_Local,iLowest (Symbol(),timeframe_Local,MODE_LOW,iBarShift (Symbol(),timeframe_Local,f_time [f][shiftLocal],false),0)) >= f_price [f][shiftLocal]
            && iHigh (Symbol (),timeframe_Local,iHighest (Symbol(),timeframe_Local,MODE_HIGH,iBarShift (Symbol(),timeframe_Local,f_time [f][shiftLocal],false),0)) <= f_price [f][shiftLocal+1])
               {
               
               outsideSwing_Sell_Length [f] = f_length [f][shiftLocal];
               outsideSwing_Sell_Duration [f] = f_duration [f][shiftLocal];
               outsideSwing_Sell_Angle [f] = NormalizeDouble (f_angle [f][shiftLocal],3);
               outsideSwing_Sell_Shift [f] = shiftLocal;
               outsideSwing_Sell_PB_WC [f] = shiftLocal;
               outsideSwing_Sell_PriceStart [f] = f_price [f][shiftLocal+1];
               outsideSwing_Sell_PriceEnd [f] = f_price [f][shiftLocal];
               outsideSwing_Sell_TimeStart [f] = f_time [f][shiftLocal+1];
               outsideSwing_Sell_TimeEnd [f] = f_time [f][shiftLocal];
               outsideSwing_Sell_PriceCorrection_0660 [f] = f_price [f][shiftLocal] + 0.66 * MathAbs (outsideSwing_Sell_Length [f]) * Point;
               outsideSwing_Sell_PriceCorrector [f] = f_price [f][shiftLocal+2];
               outsideSwing_Sell_PriceCheck [f] = 0.5 * (outsideSwing_Sell_PriceCorrection_0660 [f] + outsideSwing_Sell_PriceCorrector [f]);
               outsideSwing_Sell_PriceControl [f] = f_price [f][shiftLocal] + 0.34 * MathAbs (outsideSwing_Sell_Length [f]) * Point;
               outsideSwing_Sell_PB_length [f] = (f_price [f][0] - f_price [f][shiftLocal]) / Point;
               outsideSwing_Sell_PB_length_max [f] = (iHigh (Symbol (),timeframe_Local,iHighest (Symbol(),5,MODE_HIGH,iBarShift (Symbol(),timeframe_Local,f_time [f][shiftLocal],false),0)) >= f_price [f][shiftLocal+1] - f_price [f][shiftLocal]) / Point;
               if (f_length [f][0] > 0) outsideSwing_Sell_PriceGoal [f] = f_price [f][0] - MathAbs (outsideSwing_Sell_Length [f]) * Point;
               if (f_length [f][0] < 0) outsideSwing_Sell_PriceGoal [f] = f_price [f][1] - MathAbs (outsideSwing_Sell_Length [f]) * Point;
               outsideSwing_Sell_PB_duration [f] = TimeCurrent () - f_time [f][shiftLocal];
               if (outsideSwing_Sell_Length [f] != 0) outsideSwing_Sell_PB_ratio [f] = NormalizeDouble (MathAbs (outsideSwing_Sell_PB_length [f] / outsideSwing_Sell_Length [f]),2);
               if (outsideSwing_Sell_Length [f] != 0) outsideSwing_Sell_PB_ratio_max [f] = NormalizeDouble (MathAbs (outsideSwing_Sell_PB_length_max [f] / outsideSwing_Sell_Length [f]),2);
               if (outsideSwing_Sell_PB_duration [f] != 0) outsideSwing_Sell_PB_angle [f] = NormalizeDouble (outsideSwing_Sell_PB_length [f] / outsideSwing_Sell_PB_duration [f],2);
               if (outsideSwing_Sell_PB_duration [f] != 0) outsideSwing_Sell_PB_angle_max [f] = NormalizeDouble (outsideSwing_Sell_PB_length_max [f] / outsideSwing_Sell_PB_duration [f],2);
               
               }
         
         }
      }
   
   }
   
   


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool check_outsideswing (int directionLocal, int fNumberStart, int fNumberEnd)
   {
   
   int shift;
   
   if (directionLocal == -1)
      {
      for (int f = fNumberStart; f <= fNumberEnd; f++)
         {
         shift = outsideSwing_Sell_Shift [f];
         if (outsideSwing_Sell_Length [f] < 0
            && outsideSwing_Sell_PB_WC [f] >= 3
            && f_length [f][0] > 0
            && f_price [f][0] >= 0.5 * (outsideSwing_Sell_PriceStart [f] + outsideSwing_Sell_PriceEnd [f])
            && (MathAbs (f_length [f][shift-1]) < 0.7 * MathAbs (outsideSwing_Sell_Length [f]) // либо перва€ волна отката слаба€
               || MathAbs (f_length [f][shift-2]) > 0.7 * MathAbs (f_length [f][shift-1]) // либо две нижние вершины близко
               || f_price [f][shift-1] < f_price [f][shift+2] // либо перва€ волна не откатила до корректира ќ—
               || outsideSwing_Sell_PB_WC [f] >= 5))
               {
               return (true);
               }
         }
      }
            

   if (directionLocal == 1)
      {
      for (f = fNumberStart; f <= fNumberEnd; f++)
         {
         shift = outsideSwing_Buy_Shift [f];
         if (outsideSwing_Buy_Length [f] > 0
            && outsideSwing_Buy_PB_WC [f] >= 3
            && f_length [f][0] < 0
            && f_price [f][0] <= 0.5 * (outsideSwing_Buy_PriceStart [f] + outsideSwing_Buy_PriceEnd [f])
            && (MathAbs (f_length [f][shift-1]) < 0.7 * MathAbs (outsideSwing_Sell_Length [f]) // либо перва€ волна отката слаба€
               || MathAbs (f_length [f][shift-2]) > 0.7 * MathAbs (f_length [f][shift-1]) // либо две нижние вершины близко
               || f_price [f][shift-1] > f_price [f][shift+2] // либо перва€ волна не откатила до корректира ќ—
               || outsideSwing_Buy_PB_WC [f] >= 5))
               {
               return (true);
               }
         }
      }
   
   return (false);
   
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double sum_length (int fNumberLocal, int shiftStart, int shiftEnd)
   {
   
   double lengthTotalLocal = 0;
   int shift1, shift0;
   
   if (shiftStart > shiftEnd) {shift1 = shiftStart; shift0 = shiftEnd;}
   if (shiftStart < shiftEnd) {shift0 = shiftStart; shift1 = shiftEnd;}
   
   for (int pos  = shift0; pos <= shift1; pos++)
      {
      lengthTotalLocal += f_length [fNumberLocal][pos];
      }
   return (lengthTotalLocal);
   }
   




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int sum_duration (int fNumberLocal, int shiftStart, int shiftEnd)
   {
   
   double durationTotalLocal = 0;
   int shift1, shift0;
   
   if (shiftStart > shiftEnd) {shift1 = shiftStart; shift0 = shiftEnd;}
   if (shiftStart < shiftEnd) {shift0 = shiftStart; shift1 = shiftEnd;}
   
   for (int pos  = shift0; pos <= shift1; pos++)
      {
      durationTotalLocal += f_duration [fNumberLocal][pos];
      }
   return (durationTotalLocal);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double max_swing (int fNumberLocal, int directionLocal, int shiftStartLocal)
   {
   
   double max_swing_local = 0;
   
   if (directionLocal == 1)
      {
      for (int index = shiftStartLocal; index >= 0; index--)
         {
         if (f_length [fNumberLocal][index] > 0
            && f_length [fNumberLocal][index] > max_swing_local) max_swing_local = f_length [fNumberLocal][index];
         }
      }
   
   if (directionLocal == -1)
      {
      for (index = shiftStartLocal; index >= 0; index--)
         {
         if (f_length [fNumberLocal][index] < 0
            && MathAbs (f_length [fNumberLocal][index]) > MathAbs (max_swing_local)) max_swing_local = f_length [fNumberLocal][index];
         }
      }
   
   return (max_swing_local);
   
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double price_extremum (int fNumberLocal, int directionLocal, int shiftStartLocal)
   
   {
   
   double price_extremum_local = f_price [fNumberLocal][shiftStartLocal];
   
   if (directionLocal == 1)
      {
      for (int index = shiftStartLocal; index >= 1; index--)
         {
         if (f_price [fNumberLocal][index] < f_price [fNumberLocal][index]) price_extremum_local = f_price [fNumberLocal][index];
         }
      }
   
   if (directionLocal == -1)
      {
      for (index = shiftStartLocal; index >= 1; index--)
         {
         if (f_price [fNumberLocal][index] > f_price [fNumberLocal][index]) price_extremum_local = f_price [fNumberLocal][index];
         }
      }
   
   return (price_extremum_local);

   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int get_f_wave_shift_start (int timeStartLocal,int fNumberLocal)
   {
   
   for (int index = 0; index <= f_swings_max [fNumberLocal]; index++)
      {
      
      if (f_time [fNumberLocal][index] > timeStartLocal
         && f_time [fNumberLocal][index+1] < timeStartLocal
         && f_time [fNumberLocal][0] >= timeStartLocal) return (index+1);
      
      if (f_time [fNumberLocal][0] <= timeStartLocal) return (1);
      
      }
   
   return (0);
   
   }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double f_price_max (int fNumberLocal, int timeStartLocal, int timeEndLocal)
   {
   
   double priceMaxLocal = 0;
   
   for (int index = 1; index <= f_swings_max [fNumberLocal]; index++)
      {
      
      if (f_time [fNumberLocal][index] < timeStartLocal) break;
      
      if (f_price [fNumberLocal][index] > priceMaxLocal
         && f_time [fNumberLocal][index] <= timeEndLocal) priceMaxLocal = f_price [fNumberLocal][index];
      
      }
   
   return (priceMaxLocal);
   
   }
 
 
 
 
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double f_price_min (int fNumberLocal, int timeStartLocal, int timeEndLocal)
   {
   
   double priceMinLocal = 0;
   
   for (int index = 1; index <= f_swings_max [fNumberLocal]; index++)
      {
      
      if (f_time [fNumberLocal][index] < timeStartLocal) break;
      
      if (priceMinLocal == 0
         && f_time [fNumberLocal][index] <= timeEndLocal) priceMinLocal = f_price [fNumberLocal][index];
      
      if (f_price [fNumberLocal][index] < priceMinLocal
         && f_time [fNumberLocal][index] <= timeEndLocal) priceMinLocal = f_price [fNumberLocal][index];
      
      }
   
   return (priceMinLocal);
   
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int vertex_find_index (int directionLocal, int fNumberLocal, double priceLimit)
   {
   
   if (directionLocal == 1)
      {
      for (int index = 0; index <= f_swings_max [fNumberLocal]; index++)
         {
         if (f_price [fNumberLocal][index] > priceLimit) return (index);
         }
      }
   
   if (directionLocal == -1)
      {
      for (index = 0; index <= f_swings_max [fNumberLocal]; index++)
         {
         if (f_price [fNumberLocal][index] < priceLimit) return (index);
         }
      }
   
   return (-1);
   
   }

