#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

input string DateList = "2026.01.02,2026.01.05,2026.01.06";
input bool ShowHVN = true;
input bool ShowLVN = true;
input color HVNColor = clrDodgerBlue;
input color LVNColor = clrOrange;

string g_dates[];
string g_prefix = "HVN_LVN_";

bool ParseDates()
{
   string parts[];
   int total = StringSplit(DateList, ',', parts);
   if(total <= 0)
      return false;

   ArrayResize(g_dates, 0);

   for(int i = 0; i < total; i++)
   {
      string s = StringTrimLeft(StringTrimRight(parts[i]));
      if(s == "")
         continue;

      datetime dt = StringToTime(s + " 00:00:00");
      if(dt == 0)
         continue;

      int idx = ArraySize(g_dates);
      ArrayResize(g_dates, idx + 1);
      g_dates[idx] = TimeToString(dt, TIME_DATE);
   }

   return ArraySize(g_dates) > 0;
}

bool IsTargetDate(datetime t)
{
   string currentDate = TimeToString(t, TIME_DATE);

   for(int i = 0; i < ArraySize(g_dates); i++)
   {
      if(currentDate == g_dates[i])
         return true;
   }

   return false;
}

void DeleteByPrefix(string prefix)
{
   int total = ObjectsTotal(0, 0, -1);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, prefix) == 0)
         ObjectDelete(0, name);
   }
}

void DrawSignal(string signalType, int barIndex, double price, color col)
{
   string dateText = TimeToString(Time[barIndex], TIME_DATE);
   string objectName = StringFormat("%s%s_%s", g_prefix, dateText, signalType);

   if(ObjectFind(0, objectName) >= 0)
      ObjectDelete(0, objectName);

   ObjectCreate(0, objectName, OBJ_TEXT, 0, Time[barIndex], price);
   ObjectSetString(0, objectName, OBJPROP_TEXT, signalType);
   ObjectSetInteger(0, objectName, OBJPROP_COLOR, col);
   ObjectSetInteger(0, objectName, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, objectName, OBJPROP_FONT, "Arial Bold");
   ObjectSetInteger(0, objectName, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
}

int OnInit()
{
   if(!ParseDates())
   {
      Print("DateList is empty or invalid.");
      return(INIT_FAILED);
   }

   DeleteByPrefix(g_prefix);
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
   if(rates_total < 2)
      return rates_total;

   int start = prev_calculated > 0 ? prev_calculated - 1 : 0;

   for(int i = start; i < rates_total; i++)
   {
      if(!IsTargetDate(time[i]))
         continue;

      int dayStart = i;
      while(dayStart > 0 && IsTargetDate(time[dayStart - 1]))
         dayStart--;

      int dayEnd = i;
      while(dayEnd + 1 < rates_total && IsTargetDate(time[dayEnd + 1]))
         dayEnd++;

      long highestVolume = volume[dayStart];
      long lowestVolume = volume[dayStart];
      int hvnIndex = dayStart;
      int lvnIndex = dayStart;

      for(int j = dayStart + 1; j <= dayEnd; j++)
      {
         if(volume[j] > highestVolume)
         {
            highestVolume = volume[j];
            hvnIndex = j;
         }

         if(volume[j] < lowestVolume)
         {
            lowestVolume = volume[j];
            lvnIndex = j;
         }
      }

      if(ShowHVN)
         DrawSignal("HVN", hvnIndex, high[hvnIndex], HVNColor);

      if(ShowLVN)
         DrawSignal("LVN", lvnIndex, low[lvnIndex], LVNColor);

      i = dayEnd;
   }

   return rates_total;
}

void OnDeinit(const int reason)
{
   DeleteByPrefix(g_prefix);
}
