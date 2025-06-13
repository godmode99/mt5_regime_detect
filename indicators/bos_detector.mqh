#ifndef BOS_DETECTOR_MQH
#define BOS_DETECTOR_MQH

//+------------------------------------------------------------------+
//| Return true if Break of Structure detected on given bar          |
//| input:  rates[] - array of price data                             |
//|         shift   - bar index to evaluate                           |
//| output: true if BOS pattern found                                 |
//+------------------------------------------------------------------+
bool DetectBOS(const MqlRates rates[], const int shift);

//+------------------------------------------------------------------+
//| Determine trend direction based on recent swings                 |
//| input:  rates[] - array of price data                             |
//|         bars    - number of bars to analyze                       |
//| output: TrendDirection enumeration value                          |
//+------------------------------------------------------------------+
TrendDirection GetTrendDirection(const MqlRates rates[], const int bars);

#endif // BOS_DETECTOR_MQH
