#ifndef EXPORT_UTILS_MQH
#define EXPORT_UTILS_MQH

#include <Files\Csv.mqh>
#include <stdlib.mqh>

//+------------------------------------------------------------------+
//| Export RegimeFeature data to CSV file                            |
//| input:  feature - calculated feature struct                      |
//| output: none                                                     |
//+------------------------------------------------------------------+
void ExportFeatureCSV(const RegimeFeature &feature);

//+------------------------------------------------------------------+
//| Export RegimeFeature data to JSON file                           |
//| input:  feature - calculated feature struct                      |
//| output: none                                                     |
//+------------------------------------------------------------------+
void ExportFeatureJSON(const RegimeFeature &feature);

//+------------------------------------------------------------------+
//| Validate fields before exporting                                 |
//| input:  feature - struct with values to check                    |
//| output: true if all fields are valid                             |
//+------------------------------------------------------------------+
bool ValidateFeature(const RegimeFeature &feature);

#endif // EXPORT_UTILS_MQH
