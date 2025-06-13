#ifndef CANDLE_MOMENTUM_MQH
#define CANDLE_MOMENTUM_MQH

//+------------------------------------------------------------------+
//| Calculate candle momentum strength                               |
//| input:  rates[] - price series                                    |
//|         shift   - bar index                                       |
//| output: CandleStrength value                                      |
//+------------------------------------------------------------------+
CandleStrength GetCandleStrength(const MqlRates rates[], const int shift);

//+------------------------------------------------------------------+
//| Determine candle direction (bull/bear)                           |
//| input:  rates[] - price series                                    |
//|         shift   - bar index                                       |
//| output: CandleDirection value                                     |
//+------------------------------------------------------------------+
CandleDirection GetCandleDirection(const MqlRates rates[], const int shift);

#endif // CANDLE_MOMENTUM_MQH
