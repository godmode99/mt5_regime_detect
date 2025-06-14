#ifndef RSI_TOOLS_MQH
#define RSI_TOOLS_MQH

//+------------------------------------------------------------------+
//| Calculate Relative Strength Index (RSI)                           |
//| input:  rates[] - price series                                    |
//|         period  - RSI period                                      |
//| output: RSI value 0-100                                           |
//+------------------------------------------------------------------+
double GetRSI(const MqlRates &rates[], const int period)
  {
   if(ArraySize(rates) <= period)
      return(50.0);
   double gain = 0.0;
   double loss = 0.0;
   for(int i=0;i<period;i++)
     {
      double diff = rates[i].close - rates[i+1].close;
      if(diff>0)
         gain += diff;
      else
         loss -= diff;
     }
   if(loss==0.0)
      return(100.0);
   double rs = gain / loss;
   return(100.0 - (100.0/(1.0 + rs)));
  }

#endif // RSI_TOOLS_MQH
