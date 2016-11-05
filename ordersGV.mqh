//+------------------------------------------------------------------+
//|                                                     ordersGV.mqh |
//|                                                   Zhinzhich Labs |
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_clear ()
   {
   for (int x = GlobalVariablesTotal (); x >= 0; x--)
      {
      if (StringSubstr (GlobalVariableName (x),0,3) == "LOT"
         || StringSubstr (GlobalVariableName (x),0,3) == "CLN"
         || StringSubstr (GlobalVariableName (x),0,3) == "TME"
         || StringSubstr (GlobalVariableName (x),0,3) == "LPR"
         || StringSubstr (GlobalVariableName (x),0,3) == "STP"
         || StringSubstr (GlobalVariableName (x),0,3) == "STH"
         || StringSubstr (GlobalVariableName (x),0,3) == "BOH"
         || StringSubstr (GlobalVariableName (x),0,3) == "LBO"
         || StringSubstr (GlobalVariableName (x),0,3) == "LBF"
         || StringSubstr (GlobalVariableName (x),0,3) == "LBP"
         || StringSubstr (GlobalVariableName (x),0,3) == "IEP"
         || StringSubstr (GlobalVariableName (x),0,3) == "IET"
         || StringSubstr (GlobalVariableName (x),0,3) == "IST"
         || StringSubstr (GlobalVariableName (x),0,3) == "TYP"
         || StringSubstr (GlobalVariableName (x),0,3) == "ROP"
         || StringSubstr (GlobalVariableName (x),0,3) == "OTP"
         || StringSubstr (GlobalVariableName (x),0,3) == "OUP"
         || StringSubstr (GlobalVariableName (x),0,3) == "OIL"
         || StringSubstr (GlobalVariableName (x),0,3) == "OID"
         || StringSubstr (GlobalVariableName (x),0,3) == "OTD"
         || StringSubstr (GlobalVariableName (x),0,3) == "OFL"
         || StringSubstr (GlobalVariableName (x),0,3) == "OFD"
         || StringSubstr (GlobalVariableName (x),0,3) == "OEP"
         || StringSubstr (GlobalVariableName (x),0,3) == "OLP"
         || StringSubstr (GlobalVariableName (x),0,3) == "IWS"
         || StringSubstr (GlobalVariableName (x),0,3) == "IWL"
         || StringSubstr (GlobalVariableName (x),0,3) == "LRP"
         || StringSubstr (GlobalVariableName (x),0,3) == "TYP"
         || StringSubstr (GlobalVariableName (x),0,3) == "OVP"
         || StringSubstr (GlobalVariableName (x),0,3) == "OVT"
         || StringSubstr (GlobalVariableName (x),0,3) == "ITE"
         || StringSubstr (GlobalVariableName (x),0,3) == "ORP") GlobalVariableDel (GlobalVariableName (x));
      }
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_set (double priceLocal, double lotLocal)
   {   
   string name = StringConcatenate ("LOT_",StringSubstr (priceLocal,StringLen (priceLocal)-5,5));   
   GlobalVariableSet (name,lotLocal);   
   name = StringConcatenate ("CLN_",StringSubstr (priceLocal,StringLen (priceLocal)-5,5));   
   GlobalVariableSet (name,0);   
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_TimeCloseLast_set (double idLocal, int timeLocal)
   {
   string name = StringConcatenate ("TME_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,timeLocal);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int order_gv_TimeCloseLast_get(double idLocal)
   {
   string name = StringConcatenate ("TME_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   int timeLocal = GlobalVariableGet (name);
   return (timeLocal);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_LOT_set (double idLocal, double numberLocal)
   {
   string name = StringConcatenate ("LOT_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,numberLocal);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_LOT_get (double idLocal)
   {
   string name = StringConcatenate ("LOT_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double lotLocal = GlobalVariableGet (name);
   return (lotLocal);
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int order_gv_CLN_get (double idLocal)
   {
   string name = StringConcatenate ("CLN_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   int numberLocal = GlobalVariableGet (name);
   return (numberLocal);
   }
   


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_CLN_set (double idLocal, int numberLocal)
   {
   string name = StringConcatenate ("CLN_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,numberLocal);
   }
   


//+------------------------------------------------------------------+
//| Get Impulse Time End                                             |
//+------------------------------------------------------------------+

int order_gv_ITE_get (double idLocal)
   {
   string name = StringConcatenate ("ITE_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   int numberLocal = GlobalVariableGet (name);
   return (numberLocal);
   }
   


//+------------------------------------------------------------------+
//| Set Impulse Time End                                             |
//+------------------------------------------------------------------+

void order_gv_ITE_set (double idLocal, int numberLocal)
   {
   string name = StringConcatenate ("ITE_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,numberLocal);
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_OUP_get (double idLocal)  // Over/Under Close Price
   {
   string name = StringConcatenate ("OUP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   int numberLocal = GlobalVariableGet (name);
   return (numberLocal);
   }
   


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_OUP_set (double idLocal, int numberLocal)
   {
   string name = StringConcatenate ("OUP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,numberLocal);
   }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_LPR_set (double idLocal, double priceLocal)
   {
   string name = StringConcatenate ("LPR_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,priceLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_LPR_get (double idLocal)
   {
   string name = StringConcatenate ("LPR_",StringSubstr (idLocal,StringLen (idLocal)-5,5));   
   double numberLocal = GlobalVariableGet (name);   
   return (numberLocal);
   }




//+------------------------------------------------------------------+
//| SET ORDER TAKE_PROFIT PRICE                                      |
//+------------------------------------------------------------------+

void order_gv_OTP_set (double idLocal, double priceLocal)
   {
   string name = StringConcatenate ("OTP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,priceLocal);
   }

//+------------------------------------------------------------------+
//| GET ORDER TAKE_PROFIT PRICE                                      |
//+------------------------------------------------------------------+

double order_gv_OTP_get (double idLocal)
   {
   string name = StringConcatenate ("OTP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double numberLocal = GlobalVariableGet (name);
   return (numberLocal);
   }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_STP_set (double idLocal, double priceLocal)
   {
   string name = StringConcatenate ("STP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,priceLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_STP_get (double idLocal)
   {
   string name = StringConcatenate ("STP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double priceLocal = GlobalVariableGet (name);
   return (priceLocal);
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_IEP_set (double idLocal, double priceLocal) // order impulse extremum
   {   
   string name = StringConcatenate ("IEP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,priceLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_IEP_get (double idLocal)
   {
   string name = StringConcatenate ("IEP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double priceLocal = GlobalVariableGet (name);
   return (priceLocal);
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_OEP_set (double idLocal, double priceLocal) // order extremum price
   {
   string name = StringConcatenate ("OEP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,priceLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_OEP_get (double idLocal)
   {
   string name = StringConcatenate ("OEP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double priceLocal = GlobalVariableGet (name);
   return (priceLocal);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_OLP_set (double idLocal, double priceLocal) // order level price
   {
   string name = StringConcatenate ("OLP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,priceLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_OLP_get (double idLocal)
   {
   string name = StringConcatenate ("OLP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double priceLocal = GlobalVariableGet (name);
   return (priceLocal);
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_IWS_set (double idLocal, double priceLocal) // order level price
   {
   string name = StringConcatenate ("IWS_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,priceLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_IWS_get (double idLocal)
   {
   string name = StringConcatenate ("IWS_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double priceLocal = GlobalVariableGet (name);
   return (priceLocal);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_LRP_set (double idLocal, double priceLocal) // order level price
   {
   string name = StringConcatenate ("LRP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,priceLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_LRP_get (double idLocal)
   {
   string name = StringConcatenate ("LRP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double priceLocal = GlobalVariableGet (name);
   return (priceLocal);
   }



//+------------------------------------------------------------------+
//| Set Opposite Vertex Price                                        |
//+------------------------------------------------------------------+

void order_gv_OVP_set (double idLocal, double priceLocal) // order level price
   {
   string name = StringConcatenate ("OVP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));   
   GlobalVariableSet (name,priceLocal);
   }



//+------------------------------------------------------------------+
//| Get Opposite Vertex Price                                        |
//+------------------------------------------------------------------+

double order_gv_OVP_get (double idLocal)
   {
   string name = StringConcatenate ("OVP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double priceLocal = GlobalVariableGet (name);
   return (priceLocal);
   }



//+------------------------------------------------------------------+
//| Set Opposite Vertex Time                                         |
//+------------------------------------------------------------------+

void order_gv_OVT_set (double idLocal, double priceLocal) // order level price
   {
   string name = StringConcatenate ("OVT_",StringSubstr (idLocal,StringLen (idLocal)-5,5));   
   GlobalVariableSet (name,priceLocal);
   }



//+------------------------------------------------------------------+
//| Get Opposite Vertex Time                                         |
//+------------------------------------------------------------------+

double order_gv_OVT_get (double idLocal)
   {
   string name = StringConcatenate ("OVT_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double priceLocal = GlobalVariableGet (name);
   return (priceLocal);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_IWL_set (double idLocal, double lengthLocal) // order level price
   {
   string name = StringConcatenate ("IWL_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,lengthLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_IWL_get (double idLocal)
   {
   string name = StringConcatenate ("IWL_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double lengthLocal = GlobalVariableGet (name);
   return (lengthLocal);
   }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_IET_set (double idLocal, double timeLocal) // order impulse extremum
   {   
   string name = StringConcatenate ("IET_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,timeLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int order_gv_IET_get (double idLocal)
   {
   string name = StringConcatenate ("IET_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   int timeLocal = (int) GlobalVariableGet (name);
   return (timeLocal);
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_IST_set (double idLocal, double timeLocal) // order impulse start time
   {
   string name = StringConcatenate ("IST_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,timeLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int order_gv_IST_get (double idLocal)
   {
   string name = StringConcatenate ("IST_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   int timeLocal = (int) GlobalVariableGet (name);
   return (timeLocal);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_OIL_set (double idLocal, double lengthLocal) // order impulse length
   {
   string name = StringConcatenate ("OIL_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,lengthLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_OIL_get (double idLocal)
   {
   string name = StringConcatenate ("OIL_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double lengthLocal = GlobalVariableGet (name);
   return (lengthLocal);
   }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_OFL_set (double idLocal, double lengthLocal) // order impulse length
   {
   string name = StringConcatenate ("OFL_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,lengthLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_OFL_get (double idLocal)
   {
   string name = StringConcatenate ("OFL_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   double lengthLocal = GlobalVariableGet (name);
   return (lengthLocal);
   }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_OID_set (double idLocal, double durationLocal) // order impulse duration
   {   
   string name = StringConcatenate ("OID_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   GlobalVariableSet (name,durationLocal);
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int order_gv_OID_get (double idLocal)
   {
   string name = StringConcatenate ("OID_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   int durationLocal = (int) GlobalVariableGet (name);
   return (durationLocal);
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_OFD_set (double idLocal, double durationLocal) // order fractal duration
   {
   
   string name = StringConcatenate ("OFD_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,durationLocal);
   
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int order_gv_OFD_get (double idLocal)
   {
   
   string name = StringConcatenate ("OFD_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   int durationLocal = (int) GlobalVariableGet (name);
   
   if (durationLocal > 0) return (durationLocal);
   
   return (-1);
   
   }
   




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_OTD_set (double idLocal, double durationLocal) // order trendline duration
   {
   
   string name = StringConcatenate ("OTD_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,durationLocal);
   
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int order_gv_OTD_get (double idLocal)
   {
   
   string name = StringConcatenate ("OTD_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   int durationLocal = (int) GlobalVariableGet (name);
   
   if (durationLocal > 0) return (durationLocal);
   
   return (-1);
   
   }




 


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_STH_set (double idLocal, double SL_hit)
   {
   
   string nameString = DoubleToStr (idLocal,5);
   
   string name = StringConcatenate ("STH_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,SL_hit);
   
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_STH_get (double idLocal)
   {
   
   string name = StringConcatenate ("STH_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   double result = GlobalVariableGet (name);
   
   return (result);
   
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_CID_set (double idLocal, double SL_hit) // Close by Impulse Duration
   {
   
   string nameString = DoubleToStr (idLocal,5);
   
   string name = StringConcatenate ("CID_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,SL_hit);
   
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_CID_get (double idLocal)
   {
   
   string name = StringConcatenate ("CID_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   double result = GlobalVariableGet (name);
   
   return (result);
   
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_C13_set (double idLocal, double SL_hit) // Close by Impulse Duration
   {
   
   string nameString = DoubleToStr (idLocal,5);
   
   string name = StringConcatenate ("C13_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,SL_hit);
   
   }

   
   
   
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_C13_get (double idLocal)
   {
   
   string name = StringConcatenate ("C13_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   double result = GlobalVariableGet (name);
   
   return (result);
   
   }






//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_CIL_set (double idLocal, double SL_hit) // Close by Impulse Length
   {
   
   string nameString = DoubleToStr (idLocal,5);
   
   string name = StringConcatenate ("CIL_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,SL_hit);
   
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_CIL_get (double idLocal)
   {
   
   string name = StringConcatenate ("CIL_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   double result = GlobalVariableGet (name);
   
   return (result);
   
   }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_BOH_set (double idLocal, double BO_hit)
   {
   
   string nameString = DoubleToStr (idLocal,5);
   
   string name = StringConcatenate ("BOH_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,BO_hit);
   
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_BOH_get (double idLocal)
   {
   
   string name = StringConcatenate ("BOH_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   double result = GlobalVariableGet (name);
   
   return (result);
   
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_ROP_set (double idLocal, double price) // Repair Order last Price
   {
   
   string nameString = DoubleToStr (idLocal,5);
   
   string name = StringConcatenate ("ROP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,price);
   
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_ROP_get (double idLocal)
   {
   
   string name = StringConcatenate ("ROP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   double result = GlobalVariableGet (name);
   
   return (result);
   
   }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_TYP_set (double idLocal, double Type)
   {
   
   string nameString = DoubleToStr (idLocal,5);
   
   string name = StringConcatenate ("TYP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,Type);
   
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_TYP_get (double idLocal)
   {
   
   string name = StringConcatenate ("TYP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   double result = GlobalVariableGet (name);
   
   return (result);
   
   }




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_ORP_set (double idLocal, double Type)
   {
   
   string nameString = DoubleToStr (idLocal,5);
   
   string name = StringConcatenate ("ORP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,Type);
   
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_ORP_get (double idLocal)
   {
   
   string name = StringConcatenate ("ORP_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   double result = GlobalVariableGet (name);
   
   return (result);
   
   }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_LBF_set (double idLocal, double LBF_set) // Level Breakout Flag
   {
   
   string nameString = DoubleToStr (idLocal,5);
   
   string name = StringConcatenate ("LBF_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,LBF_set);
   
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_LBF_get (double idLocal)
   {
   
   string name = StringConcatenate ("LBF_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   double result = GlobalVariableGet (name);
   
   return (result);
   
   }





//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void order_gv_LBO_set (double idLocal, double OL_hit)
   {
   
   string nameString = DoubleToStr (idLocal,5);
   
   string name = StringConcatenate ("LBO_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   GlobalVariableSet (name,OL_hit);
   
   }
   
   
   

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double order_gv_LBO_get (double idLocal)
   {
   
   string name = StringConcatenate ("LBO_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   double result = GlobalVariableGet (name);
   
   return (result);
   
   }



   
   
   

//+------------------------------------------------------------------+
//| Get Order Level                                                  |
//+------------------------------------------------------------------+

int order_gv_OLV_get (double idLocal)
   {   
   string name = StringConcatenate ("OLV_",StringSubstr (idLocal,StringLen (idLocal)-5,5));
   
   double result = GlobalVariableGet (name);
   
   return (result);
   
   }