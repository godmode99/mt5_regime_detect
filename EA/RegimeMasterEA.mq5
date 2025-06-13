#include "features_struct.mqh"
#include "ExportUtils.mqh"
#include "..\indicators\bos_detector.mqh"
#include "..\indicators\sweep_detector.mqh"
#include "..\indicators\volume_tools.mqh"
#include "..\indicators\ob_retest.mqh"
#include "..\indicators\candle_momentum.mqh"
#include "..\indicators\session_tools.mqh"

// Expert initialization function
int OnInit()
  {
   // TODO: initialization logic
   return(INIT_SUCCEEDED);
  }

// Expert deinitialization function
void OnDeinit(const int reason)
  {
   // TODO: cleanup logic
  }

// Expert tick function
void OnTick()
  {
   // TODO: main regime detection workflow
  }
