#ifndef SWEEP_DETECTOR_MQH
#define SWEEP_DETECTOR_MQH

//+------------------------------------------------------------------+
//| Detect liquidity sweep or fake breakout                          |
//| input:  rates[] - array of price data                             |
//|         shift   - bar index to evaluate                           |
//| output: true if sweep pattern detected                            |
//+------------------------------------------------------------------+
bool DetectSweep(const MqlRates rates[], const int shift);

//+------------------------------------------------------------------+
//| Check for range compression / expansion                          |
//| input:  rates[] - price series                                    |
//|         bars    - bars to evaluate                                |
//| output: true if compression detected                              |
//+------------------------------------------------------------------+
bool DetectRangeCompression(const MqlRates rates[], const int bars);

#endif // SWEEP_DETECTOR_MQH
