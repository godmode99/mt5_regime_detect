#ifndef OB_RETEST_MQH
#define OB_RETEST_MQH

//+------------------------------------------------------------------+
//| Detect Order Block retest or trap                                |
//| input:  rates[] - price series                                    |
//|         shift   - bar index to evaluate                           |
//| output: true if retest pattern found                              |
//+------------------------------------------------------------------+
bool DetectOBRetest(const MqlRates rates[], const int shift);

//+------------------------------------------------------------------+
//| Identify potential trap areas                                    |
//| input:  rates[] - price series                                    |
//|         bars    - analysis window                                 |
//| output: true if trap zone detected                                |
//+------------------------------------------------------------------+
bool DetectTrapZone(const MqlRates rates[], const int bars);

#endif // OB_RETEST_MQH
