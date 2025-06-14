#ifndef RSI_DISPLAY_MQH
#define RSI_DISPLAY_MQH

#ifdef RSI_DISPLAY_INDICATOR

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_label1  "RSI"
#property indicator_type2   DRAW_LINE
#property indicator_label2  "LevelLow"
#property indicator_type3   DRAW_LINE
#property indicator_label3  "LevelMid"
#property indicator_type4   DRAW_LINE
#property indicator_label4  "LevelHigh"

input int   InpRSIPeriod      = 14;       // RSI period
input int   InpLevelLow       = 30;       // lower level
input int   InpLevelMid       = 50;       // middle level
input int   InpLevelHigh      = 70;       // upper level
input color InpAboveColor     = clrLime;  // color above upper level
input color InpBelowColor     = clrRed;   // color below lower level
input color InpNeutralColor   = clrSilver;// color between levels

double g_rsi_buffer[];
color  g_color_buffer[];
double g_low_buffer[];
double g_mid_buffer[];
double g_high_buffer[];
int    g_rsi_handle = INVALID_HANDLE;

int OnInit()
  {
   SetIndexBuffer(0,g_rsi_buffer,INDICATOR_DATA);
   SetIndexBuffer(1,g_color_buffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,g_low_buffer,INDICATOR_DATA);
   SetIndexBuffer(3,g_mid_buffer,INDICATOR_DATA);
   SetIndexBuffer(4,g_high_buffer,INDICATOR_DATA);

   PlotIndexSetString(0,PLOT_LABEL,"RSI");
   PlotIndexSetString(1,PLOT_LABEL,"LevelLow");
   PlotIndexSetString(2,PLOT_LABEL,"LevelMid");
   PlotIndexSetString(3,PLOT_LABEL,"LevelHigh");

   PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrGray);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,clrGray);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,clrGray);

   g_rsi_handle = iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);
   return(INIT_SUCCEEDED);
  }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int start = (prev_calculated==0) ? 0 : prev_calculated-1;
   if(CopyBuffer(g_rsi_handle,0,start,rates_total-start,g_rsi_buffer)<=0)
      return(0);

   for(int i=start;i<rates_total;i++)
     {
      g_low_buffer[i]  = InpLevelLow;
      g_mid_buffer[i]  = InpLevelMid;
      g_high_buffer[i] = InpLevelHigh;

      if(g_rsi_buffer[i]>InpLevelHigh)
         g_color_buffer[i] = InpAboveColor;
      else if(g_rsi_buffer[i]<InpLevelLow)
         g_color_buffer[i] = InpBelowColor;
      else
         g_color_buffer[i] = InpNeutralColor;
     }
   return(rates_total);
  }

#endif // RSI_DISPLAY_INDICATOR

#endif // RSI_DISPLAY_MQH
