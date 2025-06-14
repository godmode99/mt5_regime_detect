#ifndef MA_SLOPE_MQH
#define MA_SLOPE_MQH

//+------------------------------------------------------------------+
//| Calculate slope of a simple moving average                        |
//| input:  rates[] - price series                                    |
//|         period  - number of bars for MA calculation               |
//| output: difference between current MA and previous period MA      |
//+------------------------------------------------------------------+
double GetMASlope(const MqlRates rates[], const int period)
  {
   if(ArraySize(rates) <= period*2)
      return(0.0);
   double sum_recent = 0.0;
   for(int i=0;i<period;i++)
      sum_recent += rates[i].close;
   double sum_prev = 0.0;
   for(int i=period;i<period*2;i++)
      sum_prev += rates[i].close;
   double ma_recent = sum_recent/period;
   double ma_prev   = sum_prev/period;
   return(ma_recent - ma_prev);
  }

#endif // MA_SLOPE_MQH
