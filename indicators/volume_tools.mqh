#ifndef VOLUME_TOOLS_MQH
#define VOLUME_TOOLS_MQH

//+------------------------------------------------------------------+
//| Detect volume spike confirmation                                 |
//| input:  volumes[] - array of volume data                          |
//|         shift     - bar index                                     |
//| output: true if spike detected                                    |
//+------------------------------------------------------------------+
bool DetectVolumeSpike(const long volumes[], const int shift);

//+------------------------------------------------------------------+
//| Detect volume divergence                                         |
//| input:  volumes[] - volume series                                 |
//|         prices[]  - corresponding price data                      |
//|         shift     - bar index                                     |
//| output: true if divergence found                                  |
//+------------------------------------------------------------------+
bool DetectVolumeDivergence(const long volumes[], const MqlRates prices[], const int shift);

#endif // VOLUME_TOOLS_MQH
