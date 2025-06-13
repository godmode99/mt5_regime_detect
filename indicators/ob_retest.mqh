#ifndef OB_RETEST_MQH
#define OB_RETEST_MQH

//+------------------------------------------------------------------+
//| Detect Order Block retest or trap                                |
//| input:  rates[] - price series                                    |
//|         shift   - bar index to evaluate                           |
//| output: true if retest pattern found                              |
//+------------------------------------------------------------------+
bool DetectOBRetest(const MqlRates rates[], const int shift)
  {
   if(shift+1>=ArraySize(rates))
      return(false);
   double prev_high=rates[shift+1].high;
   double prev_low =rates[shift+1].low;
   bool down_retest=(rates[shift].high>prev_high && rates[shift].close<prev_high);
   bool up_retest  =(rates[shift].low <prev_low  && rates[shift].close>prev_low);
   return(down_retest||up_retest);
  }

//+------------------------------------------------------------------+
//| Identify potential trap areas                                    |
//| input:  rates[] - price series                                    |
//|         bars    - analysis window                                 |
//| output: true if trap zone detected                                |
//+------------------------------------------------------------------+
bool DetectTrapZone(const MqlRates rates[], const int bars)
  {
   if(bars<=0 || ArraySize(rates)<=bars)
      return(false);
   double max_high=rates[1].high;
   double min_low =rates[1].low;
   for(int i=2;i<=bars;i++)
     {
      if(rates[i].high>max_high) max_high=rates[i].high;
      if(rates[i].low <min_low)  min_low =rates[i].low;
     }
   double range=max_high-min_low;
   if(range<=0.0)
      return(false);
   double threshold=range*0.2;
   return(rates[0].close>max_high-threshold || rates[0].close<min_low+threshold);
  }

#endif // OB_RETEST_MQH
