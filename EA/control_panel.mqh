#ifndef CONTROL_PANEL_MQH
#define CONTROL_PANEL_MQH

#include "features_struct.mqh"

#define PANEL_BG   "feature_panel"
#define EXPORT_BTN "export_btn"

// global flag to control CSV exporting
bool g_export_enabled = true;

//+------------------------------------------------------------------+
//| Initialize chart control panel                                   |
//+------------------------------------------------------------------+
void InitPanel()
  {
   // background rectangle label
   if(!ObjectFind(0,PANEL_BG))
     {
      ObjectCreate(0,PANEL_BG,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_XDISTANCE,10);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_YDISTANCE,20);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_XSIZE,160);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_YSIZE,80);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_COLOR,clrDimGray);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_BACK,true);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,PANEL_BG,OBJPROP_SELECTABLE,false);
     }

   // export toggle button
   if(!ObjectFind(0,EXPORT_BTN))
     {
      ObjectCreate(0,EXPORT_BTN,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,EXPORT_BTN,OBJPROP_XDISTANCE,20);
      ObjectSetInteger(0,EXPORT_BTN,OBJPROP_YDISTANCE,110);
      ObjectSetInteger(0,EXPORT_BTN,OBJPROP_XSIZE,100);
      ObjectSetInteger(0,EXPORT_BTN,OBJPROP_YSIZE,20);
      ObjectSetInteger(0,EXPORT_BTN,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetString(0,EXPORT_BTN,OBJPROP_TEXT,"Export ON");
     }
  }

//+------------------------------------------------------------------+
//| Update panel with latest feature values                          |
//+------------------------------------------------------------------+
void UpdatePanel(const RegimeFeature &feature)
  {
   string txt = StringFormat("ATR: %.2f\nStdDev: %.2f\nBOS: %d\nVolSpike: %d",
                             feature.atr,
                             feature.stddev,
                             (int)feature.bos,
                             (int)feature.volume_spike);
   ObjectSetString(0,PANEL_BG,OBJPROP_TEXT,txt);
   ObjectSetString(0,EXPORT_BTN,OBJPROP_TEXT,
                   g_export_enabled?"Export ON":"Export OFF");
  }

//+------------------------------------------------------------------+
//| Handle chart events for panel                                    |
//+------------------------------------------------------------------+
void PanelOnChartEvent(const int id,const long &lparam,
                       const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK && sparam==EXPORT_BTN)
     {
      g_export_enabled = !g_export_enabled;
      ObjectSetString(0,EXPORT_BTN,OBJPROP_TEXT,
                      g_export_enabled?"Export ON":"Export OFF");
     }
  }

#endif // CONTROL_PANEL_MQH
