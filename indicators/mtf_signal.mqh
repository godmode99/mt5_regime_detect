#ifndef MTF_SIGNAL_MQH
#define MTF_SIGNAL_MQH

//+------------------------------------------------------------------+
//| Calculate multi time frame signal                                |
//| input:  rates[] - price series                                   |
//|         bars    - number of bars to analyze                      |
//| output: integer signal code                                      |
//+------------------------------------------------------------------+
int GetMTFSignal(const MqlRates rates[], const int bars)
  {
   //--- gather higher and lower timeframe data
   MqlRates htf[];                     // H1 timeframe for broader trend/BOS
   MqlRates ltf[];                     // M5 timeframe for volume confirmation

   ArraySetAsSeries(htf,true);
   ArraySetAsSeries(ltf,true);

   // CopyRates returns number of elements copied; we request bars+1 to
   // align index 0 with the latest bar across timeframes
   int copied_htf = CopyRates(_Symbol,PERIOD_H1,0,bars+1,htf);
   int copied_ltf = CopyRates(_Symbol,PERIOD_M5,0,bars+1,ltf);

   // if history is missing fall back to neutral signal
   if(copied_htf<=0 || copied_ltf<=0 || ArraySize(rates)<=bars)
      return(0);

   //--- aggregate signals using helper
   return(AggregateMTFSignal(htf, ltf, bars));
  }

#endif // MTF_SIGNAL_MQH
