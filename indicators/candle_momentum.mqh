#ifndef CANDLE_MOMENTUM_MQH
#define CANDLE_MOMENTUM_MQH

//+------------------------------------------------------------------+
//| Calculate candle momentum strength                               |
//| input:  rates[] - price series                                    |
//|         shift   - bar index                                       |
//| output: CandleStrength value                                      |
//+------------------------------------------------------------------+
CandleStrength GetCandleStrength(const MqlRates rates[], const int shift)
  {
   if(shift>=ArraySize(rates))
      return(STRENGTH_NONE);

   double body=MathAbs(rates[shift].close - rates[shift].open);
   double range=rates[shift].high - rates[shift].low;
   if(range<=0.0)
      return(STRENGTH_NONE);

   double ratio=body/range;
   if(ratio>0.6)
      return(STRENGTH_STRONG);
   if(ratio>0.3)
      return(STRENGTH_WEAK);
   return(STRENGTH_NONE);
  }

//+------------------------------------------------------------------+
//| Determine candle direction (bull/bear)                           |
//| input:  rates[] - price series                                    |
//|         shift   - bar index                                       |
//| output: CandleDirection value                                     |
//+------------------------------------------------------------------+
CandleDirection GetCandleDirection(const MqlRates rates[], const int shift)
  {
   if(shift>=ArraySize(rates))
      return(DIR_NONE);
   double diff=rates[shift].close - rates[shift].open;
   if(diff>0)
      return(DIR_BULL);
   if(diff<0)
      return(DIR_BEAR);
   return(DIR_NONE);
  }

#endif // CANDLE_MOMENTUM_MQH
