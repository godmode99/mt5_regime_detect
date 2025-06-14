#ifndef ATR_TOOLS_MQH
#define ATR_TOOLS_MQH

//+------------------------------------------------------------------+
//| Calculate Average True Range (ATR)                               |
//| input:  rates[] - price series                                   |
//|         period  - number of bars for ATR calculation             |
//| output: ATR value                                                |
//+------------------------------------------------------------------+
double CalcATR(const MqlRates rates[], const int period)
  {
   if(ArraySize(rates)<=period)
      return(0.0);
   double sum = 0.0;
   for(int i=0;i<period;i++)
     {
      double tr = rates[i].high - rates[i].low;
      if(i+1 < ArraySize(rates))
        {
         double diff1 = MathAbs(rates[i].high - rates[i+1].close);
         double diff2 = MathAbs(rates[i].low  - rates[i+1].close);
         tr = MathMax(tr, MathMax(diff1,diff2));
        }
      sum += tr;
     }
   return(sum/period);
  }

//+------------------------------------------------------------------+
//| Calculate standard deviation of closing prices                   |
//| input:  rates[] - price series                                   |
//|         period  - bars for calculation                            |
//| output: standard deviation                                       |
//+------------------------------------------------------------------+
double CalcStdDev(const MqlRates rates[], const int period)
  {
   if(ArraySize(rates)<=period)
      return(0.0);
   double sum = 0.0;
   for(int i=0;i<period;i++)
      sum += rates[i].close;
   double mean = sum/period;
   double var = 0.0;
   for(int i=0;i<period;i++)
     {
      double diff = rates[i].close - mean;
      var += diff*diff;
     }
   return(MathSqrt(var/period));
  }

#endif // ATR_TOOLS_MQH
