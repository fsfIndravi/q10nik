
//--- Logger variables

#import "mt4logger.dll";
int loggerInit(uchar &channel[] ,int,int);
int loggerAdd(int,uchar &line[],int);
int loggerShow(int,bool);
int loggerClose(int);
int loggerClear(int);
#import
// Logger variables and functions
int loggerVar=0;
void logStart(uchar &channel[],int bgcolor=Red,int txtcolor=White) {loggerVar=loggerInit(channel,bgcolor,txtcolor);}
int log(uchar &line[],int txtcolor=Black) {if(loggerVar>0) loggerAdd(loggerVar,line,txtcolor); return (0);}
int logClear() {if(loggerVar>0) loggerClear(loggerVar); return (0);}
int logClose() {if(loggerVar>0) loggerClose(loggerVar); return (0);}
uchar p [];
//---


// Stats classes

class StatsClass{
private:
public:
   class ConsoleClass{
      private:
         int      corner;        // 0-TOP-LEFT, 1-TOP-RIGHT, 2-BOTTOM-LEFT, 3-BOTTOM-RIGHT
         int      x_shift;
         int      y_shift;
         int      fontSize;
         color    baseColor;
         bool     bg;
         color    bgColor;
         int      linesMax;
         int      symbolsMax;
         string   titleText;
         
         struct   PrintLogStruct{
            int         numberLines;
            string      lineText[];
            color       lineColor[];
            };
      
      public:
         void Init (int c_corner, int c_x_shift, int c_y_shift, int c_fontSize, color c_baseColor, bool c_bg, color c_bgColor, int c_linesMax, int c_symbols_max, string c_titleText);
         void AddLine (string p_message, color p_color);
         void Redraw ();
         string Get_date_string(int time_input);
         
         // Structures initializing
         PrintLogStruct printLog;
         
         ConsoleClass ();
         
      };  // ConsoleClass
   
   // =================================================================================================== <<< ConsoleClass
   
   class LoggerClass{
      private:
         bool initialized;
      public:
         void Init (string i_versionExpert);
         void Deinit ();
   };
   
   // =================================================================================================== <<< LoggerClass
   
   // LOADING CLASSES   
   ConsoleClass console;
   LoggerClass logger;
                   
  };



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ConsoleClass::ConsoleClass(void){
   if (symbolsMax == 0 && linesMax == 0){
      corner      = 0;
      x_shift     = 5;
      y_shift     = 50;
      fontSize    = 8;
      baseColor   = DodgerBlue;
      bg          = 0;
      bgColor     = 0;
      linesMax    = 10;
      symbolsMax  = 50;
      titleText = "EXPERT CONSOLE:>";
      }
   ArrayResize (printLog.lineText, linesMax);
   ArrayResize (printLog.lineColor, linesMax);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

LoggerClass::Init (string i_versionExpert){
   StringToCharArray (i_versionExpert + " "+Symbol(),p);
   logStart(p);
   logClear();
   StringToCharArray ("Initialization has been done successfully",p);
   log(p,Green);
   initialized = true;
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

LoggerClass::Deinit ()
   {
   
   StringToCharArray ("Bye Bye___",p);
   log(p,Red);
   
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ConsoleClass::Init (int c_corner, int c_x_shift, int c_y_shift, int c_fontSize, color c_baseColor, bool c_bg, color c_bgColor, int c_linesMax, int c_symbols_max, string c_titleText)
   {
   
   corner      = c_corner;
   x_shift     = c_x_shift;
   y_shift     = c_y_shift;
   fontSize    = c_fontSize;
   baseColor   = c_baseColor;
   bg          = c_bg;
   bgColor     = c_bgColor;
   linesMax    = c_linesMax;
   symbolsMax  = c_symbols_max;
   titleText   = c_titleText;
   
   if (corner < 0) corner = 0;
   if (corner > 4) corner = 4;
   
   if (linesMax <= 0) linesMax = 10;
   if (linesMax > 30) linesMax = 30;
   
   if (symbolsMax == 0) symbolsMax = 50;
   if (symbolsMax > 256) symbolsMax = 256;
   
   }
 


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ConsoleClass::AddLine(string p_message, color p_color){
   if (p_message == printLog.lineText[0]) return;
   if (linesMax == 0) linesMax = 10;
   if (linesMax > 19) linesMax = 19;
   
   // String array rotation
   
   for (int p_pos = linesMax - 1; p_pos >= 1; p_pos--){
      printLog.lineText[p_pos] = printLog.lineText[p_pos-1];
      printLog.lineColor[p_pos] = printLog.lineColor[p_pos-1];
   }
   
   printLog.lineText[0] = p_message;
   printLog.lineColor[0] = p_color;
   
}




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

ConsoleClass::Redraw(){
   string object_text;
   string name_p;
   // Printing name line
   name_p = "Console_title";
   object_text = titleText;
   //Print ("titleText="+titleText+"   baseColor="+baseColor+"   StringLen ="+StringLen (titleText));
   if(ObjectFind (name_p) !=0) ObjectCreate(name_p, OBJ_LABEL, 0, 0, 0);
   ObjectSet(name_p, OBJPROP_CORNER, corner);
   ObjectSet(name_p, OBJPROP_XDISTANCE, x_shift);
   ObjectSet(name_p, OBJPROP_YDISTANCE, y_shift);
   ObjectSetText(name_p, object_text, fontSize, "Arial", baseColor);
   // Printing lines
   for (int line_pos = 0; line_pos <= linesMax - 1; line_pos++){
      object_text = StringSubstr (StringConcatenate (Get_date_string (TimeCurrent()),": ",printLog.lineText[line_pos]), 0, symbolsMax);
      name_p = StringConcatenate ("Console_line_",line_pos);
      // Trimming the string line if exceeds symbolsMax
      if (StringLen (printLog.lineText[line_pos]) > symbolsMax) printLog.lineText[line_pos] = StringSubstr (printLog.lineText[line_pos], 0, symbolsMax);
      if(ObjectFind (name_p) !=0) ObjectCreate(name_p, OBJ_LABEL, 0, 0, 0);
      ObjectSet(name_p, OBJPROP_CORNER, corner);
      ObjectSet(name_p, OBJPROP_XDISTANCE, x_shift);
      ObjectSet(name_p, OBJPROP_YDISTANCE, y_shift + 13 + line_pos * 13);
      ObjectSetText(name_p, object_text, fontSize, "Arial", printLog.lineColor[line_pos]);
   }
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string ConsoleClass::Get_date_string(int time_input)
  {

   string string_result=StringConcatenate(TimeYear(time_input),".",TimeMonth(time_input),".",TimeDay(time_input),"   ",TimeHour(time_input),":",TimeMinute(time_input));
   
   if (time_input == 0) string_result = "0";

   return (string_result);

  }
  

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

