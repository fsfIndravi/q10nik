//+------------------------------------------------------------------+
//|                                                 arraysZIGZAG.mqh |
//|                                                   Zhinzhich Labs |
//+------------------------------------------------------------------+

int depth [7];
int swings_max [7];
int deviation= 5;
int backstep = 3;

double f_price [7][40];
double f_length [7][40];
int f_time [7][40];
int f_shift [7][40];
int f_duration [7][40];
double f_angle [7][40];
bool f_outsideswing [7][40];
double f_duration_avg [7];
double f_length_avg [7];
color f_color[7];
int f_depth [7];



//+------------------------------------------------------------------+
//| FID?01: function initializes swing length and price levels arrays
//+------------------------------------------------------------------+

void arrays (int timeframe_Local, int fNumber)
  {
  
   int shift1 = 0;
   int shift2 = 0;
   double price1 = 0;
   double price2 = 0;
   bool price1_found = false;
   bool price2_found = false;
   double price_Highest = 0;
   double price_Lowest = 0;
   int vertex = 0;
      
   while(!price1_found){
      price1=iCustom(Symbol(),timeframe_Local,"zigzag",depth [fNumber],deviation,backstep,0,shift1);
      if(fNumber >=4 && shift1>depth [fNumber] * 12) break;
      if(price1 > 0){
         if (price1 == f_price [fNumber][0]) return; // If vertex [fNumber][0] is unchanged then exit
         price_Highest = price1;
         price_Lowest = price1;
         f_price [fNumber][0] = price1;
         f_time [fNumber][0] = iTime(Symbol(),timeframe_Local,shift1);
         f_shift [fNumber][0] = shift1;
         shift2 = shift1 + 1;
         price1_found=true;
         
         while(vertex < swings_max [fNumber]){
            price2 = iCustom(Symbol(),timeframe_Local,"zigzag",depth [fNumber],deviation,backstep,0,shift2);
            if(price2==0 || price2==price1) shift2++;
            if(fNumber >= 4 && (shift2-shift1)>depth[fNumber] * 12) break;
            if(price2>0 && price2!=price1){
               if (price2 == f_price [fNumber][1]){
                  // If vertex [fNumber][1] is unchanged then
                  // refreshing wave [0] parameters and exit
                  f_price [fNumber][1]= price2;
                  f_time [fNumber][1] = iTime(Symbol(),timeframe_Local,shift2);
                  f_shift [fNumber][1] = shift2;
                  f_length[fNumber][0]=(f_price [fNumber][0]-f_price [fNumber][1])/Point;
                  f_duration [fNumber][0] = f_time [fNumber][0] - f_time [fNumber][1];
                  if (f_duration [fNumber][0] != 0) f_angle [fNumber][0] = f_length[fNumber][0] / f_duration [fNumber][0];
                  return;
                  }
               vertex++;
               // Setting highest/lowest prices
               if (price2 < price_Lowest) price_Lowest = price2;
               if (price2 > price_Highest) price_Highest = price2;
               // Setting vertex and wave variables
               f_price [fNumber][vertex]= price2;
               f_time [fNumber][vertex] = iTime(Symbol(),timeframe_Local,shift2);                  
               f_shift [fNumber][vertex] = shift2;
               f_length[fNumber][vertex-1]=(price1-price2)/Point;
               f_duration [fNumber][vertex-1] = f_time [fNumber][vertex-1] - f_time [fNumber][vertex];
               if (f_duration [fNumber][vertex-1] != 0) f_angle [fNumber][vertex-1] = f_length[fNumber][vertex-1] / f_duration [fNumber][vertex-1];
               shift1=shift2;
               // Merging vertexes of the same direction
               if(vertex>=2){
                  if(( f_length[fNumber][vertex-2]>0 && f_length[fNumber][vertex-1]>0) || (f_length[fNumber][vertex-2]<0 && f_length[fNumber][vertex-1]<0)){
                     f_length[fNumber][vertex-2]+=f_length[fNumber][vertex-1];
                     f_duration[fNumber][vertex-2]+=f_duration[fNumber][vertex-1];
                     if (f_duration [fNumber][vertex-1] != 0) f_angle [fNumber][vertex-1] = f_length[fNumber][vertex-1] / f_duration [fNumber][vertex-1];
                     f_time[fNumber][vertex-1]=f_time[fNumber][vertex];
                     f_price[fNumber][vertex-1]=f_price[fNumber][vertex];
                     f_shift [fNumber][vertex-1] = f_shift[fNumber][vertex];
                     vertex--;
                    }
                 }
               // Setting Outsideswing variables                  
               f_outsideswing [fNumber][vertex-1] = false;
               // Outsideswing BUY
               if (f_length [fNumber][vertex-1] > 0
                  && f_price [fNumber][vertex-1] >= price_Highest 
                  && f_price [fNumber][vertex] <= price_Lowest)
                     f_outsideswing [fNumber][vertex-1] = true;
               // Outsideswing SELL
               if (f_length [fNumber][vertex-1] < 0
                  && f_price [fNumber][vertex-1] <= price_Lowest
                  && f_price [fNumber][vertex] >= price_Highest)
                     f_outsideswing [fNumber][vertex-1] = true;
               // Setting variables for the next loop
               price1=price2;
               shift2++;
              }
           }
        }
      shift1++;
   }
   }
  
  

//+-------------------------------------------------------------------------+
// FID?02: function calculates average lengths of swings using extrenal parameters
//+-------------------------------------------------------------------------+

void averages (){

   double total_length_local [7];
   int total_duration_local [7];
   double avg_number [7];
   int waves_count_local [7];
   
   for(int t=1; t<=5; t++){
     total_length_local[t]=0;
     total_duration_local [t] = 0;
     }

   for(int f=1; f<=5; f++){
      for(t = 1; t <= swings_max[f]; t++){
         if(f_length [f][t] ==0) break;
         waves_count_local [f]++;
         total_length_local [f] += MathAbs(f_length[f][t]);
         total_duration_local [f] += f_duration [f][t];
        }

      if(waves_count_local[f]!=0){
         f_length_avg [f] = NormalizeDouble (total_length_local [f] / waves_count_local [f],0);
         f_duration_avg [f] = NormalizeDouble (total_duration_local [f] / waves_count_local [f],0);
         }
     }
  }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void draw_f_number (string fNumberLocal, int directionLocal, double priceLocal, int timeLocal, int orderTicketLocal){
   
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
   
   for (int index = 0; index <= swings_max [fNumberLocal]; index++)
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
   
   for (int index = 1; index <= swings_max [fNumberLocal]; index++)
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
   
   for (int index = 1; index <= swings_max [fNumberLocal]; index++)
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

int vertex_find_index (int directionLocal, int fNumberLocal, double priceLimit){   
   
   if (directionLocal == 1){
      for (int index = 0; index <= swings_max [fNumberLocal]; index++){
         if (f_price [fNumberLocal][index] > priceLimit) return (index);
         }
      }
   
   if (directionLocal == -1){
      for (index = 0; index <= swings_max [fNumberLocal]; index++){
         if (f_price [fNumberLocal][index] < priceLimit) return (index);
         }
      }
   
   return (-1);
   
   }

