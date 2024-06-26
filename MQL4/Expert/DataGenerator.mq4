//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
datetime lastBarTime = 0; // Variable to store the last known bar time
int Cunter_print = 0;


#import "shell32.dll"
int ShellExecuteW(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
int FindExecutableW(string lpFile, string lpDirectory);
#import

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deletefile(string fileName)
  {
   if(FileIsExist(fileName,FILE_COMMON|FILE_CSV))
     {
      FileDelete(fileName,FILE_COMMON|FILE_CSV);
      Print("file deleted succssfully");
     }
   else
     {
      Print("File dose not exist");
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sending_file()
  {
   string batFilePath = "C://Users//Forex//AppData//Roaming//MetaQuotes//Terminal//Common//Files//"+Symbol()+string(ChartPeriod())+".bat";
   int result = ShellExecuteW(0, "runas", "cmd.exe", "/c " + batFilePath, NULL, 0);

   if(result > 32)
     {
      Print("File transferred successfully using ShellExecuteW.");
     }
   else
     {
      Print("Failed to transfer file using ShellExecuteW. Error code: ", result);
     }
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPrint(string objectName, string text, int fontSize, color textColor, int x, int y)
  {
//--- delete the previous object if it exists
   if(ObjectFind(objectName) != -1)
      ObjectDelete(objectName);

//--- create a new text object
   if(!ObjectCreate(objectName, OBJ_LABEL, 0, 0, 0))
     {
      Print("Failed to create text object!");
      return;
     }

//--- set object parameters
   ObjectSetString(0, objectName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objectName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objectName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, objectName, OBJPROP_COLOR, textColor);
   ObjectSetString(0, objectName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, objectName, OBJPROP_FONTSIZE, fontSize);

//--- make sure the object is not selectable or moveable
   ObjectSetInteger(0, objectName, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(0, objectName, OBJPROP_SELECTED, 0);
   ObjectSetInteger(0, objectName, OBJPROP_ZORDER, 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetCurrentTime()
  {
   datetime currentTime = TimeCurrent();
   string timeString = TimeToStr(currentTime, TIME_SECONDS);
   return timeString;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   datetime currentBarTime = iTime(_Symbol, _Period, 0);

   if(lastBarTime != currentBarTime)
     {
      lastBarTime = currentBarTime;
      return(true);
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaveChartData(int historyCount)
  {
   string fileName = Symbol() + string(StringSubstr(IntegerToString(Period()), 0)) + ".csv";

   int fileHandle = FileOpen(fileName, FILE_WRITE | FILE_CSV | FILE_COMMON);
   if(fileHandle == INVALID_HANDLE)
     {
      Print("Unable to open the file ", fileName);
      return;
     }

// ذخیره هدر در سطر اول
   FileWrite(fileHandle, "time,open,high,low,close,volume");

// ذخیره داده‌ها به ترتیب صعودی
   for(int i = historyCount - 1; i >= 1; i--)
     {
      datetime time = iTime(NULL, Period(), i);
      double open = iOpen(NULL, Period(), i);
      double high = iHigh(NULL, Period(), i);
      double low = iLow(NULL, Period(), i);
      double close = iClose(NULL, Period(), i);
      long volume = iVolume(NULL, Period(), i);

      string dataRow = StringFormat("%s,%f,%f,%f,%f,%ld",
                                    TimeToStr(time, TIME_DATE | TIME_MINUTES),
                                    open, high, low, close, volume);
      FileWrite(fileHandle, dataRow);
     }

   FileClose(fileHandle);

   Print("Data saved to ", fileName);
  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void delfile()
  {
   deletefile(Symbol()+string(ChartPeriod())+".csv");
   deletefile(Symbol()+string(ChartPeriod())+"_for_train"+".csv");

  }



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaveChartData_for_train(int historyCount)
  {
   string fileName = Symbol() + string(ChartPeriod()) + "_for_train.csv";

   int fileHandle = FileOpen(fileName, FILE_WRITE | FILE_CSV | FILE_COMMON);
   if(fileHandle == INVALID_HANDLE)
     {
      Print("Unable to open the file ", fileName);
      return;
     }

// ذخیره هدر در سطر اول
   FileWrite(fileHandle, "time,open,high,low,close,volume");

// ذخیره داده‌ها به ترتیب صعودی
   for(int i = historyCount - 1; i >= 1; i--)
     {
      datetime time = iTime(NULL, Period(), i);
      double open = iOpen(NULL, Period(), i);
      double high = iHigh(NULL, Period(), i);
      double low = iLow(NULL, Period(), i);
      double close = iClose(NULL, Period(), i);
      long volume = iVolume(NULL, Period(), i);

      string dataRow = StringFormat("%s,%f,%f,%f,%f,%ld",
                                    TimeToStr(time, TIME_DATE | TIME_MINUTES),
                                    open, high, low, close, volume);
      FileWrite(fileHandle, dataRow);
     }

   FileClose(fileHandle);

   Print("Data saved to ", fileName);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
   SaveChartData(8000);
   sending_file();
  /*MyPrint("NewBar", "LCT:"+GetCurrentTime(), 20, clrYellow, 890, 40);
   MyPrint("Write_to_File", "Stating to write to files ...", 20, clrAntiqueWhite, 10, 400);
   SaveChartData(25000);
   SaveChartData_for_train(25000);
   Sleep(3000);
   sending_file();
   MyPrint("Write_to_File", "Finish writing to files", 20, clrAntiqueWhite, 10, 400);
   Sleep(3000);
   MyPrint("Write_to_File", "", 20, clrAntiqueWhite, 10, 400);
   MyPrint("Write_to_File", "Sendig files to server ...", 20, clrAntiqueWhite, 10, 400);
   Sleep(3000);
   MyPrint("Write_to_File", "Files sent successfully ...", 20, clrAntiqueWhite, 10, 400);
   Sleep(3000);
   MyPrint("Write_to_File", "Deleting files ...", 20, clrAntiqueWhite, 10, 400);
   delfile();
   Sleep(3000);
   MyPrint("Write_to_File", "File deleted succssfully ...", 20, clrAntiqueWhite, 10, 400);
   Sleep(3000);
   MyPrint("Write_to_File", "", 20, clrAntiqueWhite, 10, 400);
   */
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {
   if(IsNewBar())
     {
     /* datetime brokerTime = TimeCurrent();
      int currentHour = TimeHour(brokerTime);
      if(((currentHour >= 0) && (currentHour <= 17)))
        {
         MyPrint("Forbidden_time", "This is forbidden time for trading Expert is off", 20, clrRoyalBlue, 250, 150);
         SaveChartData(8000);
         //SaveChartData_for_train(1500);
         Sleep(3000);
         sending_file();
         return;
        }
       
      */ MyPrint("Forbidden_time", "", 20, clrRoyalBlue, 250, 150);
      MyPrint("NewBar", "LCT:"+GetCurrentTime(), 20, clrYellow, 890, 40);
      MyPrint("Write_to_File", "Stating to write to files ...", 20, clrAntiqueWhite, 10, 400);
      SaveChartData(8000);
      //SaveChartData_for_train(1500);
      Sleep(3000);
      sending_file();
      MyPrint("Write_to_File", "Finish writing to files", 20, clrAntiqueWhite, 10, 400);
      Sleep(3000);
      MyPrint("Write_to_File", "", 20, clrAntiqueWhite, 10, 400);
      MyPrint("Write_to_File", "Sendig files to server ...", 20, clrAntiqueWhite, 10, 400);
      Sleep(3000);
      MyPrint("Write_to_File", "Files sent successfully ...", 20, clrAntiqueWhite, 10, 400);
      Sleep(3000);
      MyPrint("Write_to_File", "Deleting files ...", 20, clrAntiqueWhite, 10, 400);
      delfile();
      Sleep(3000);
      MyPrint("Write_to_File", "File deleted succssfully ...", 20, clrAntiqueWhite, 10, 400);
      Sleep(3000);
      MyPrint("Write_to_File", "", 20, clrAntiqueWhite, 10, 400);
     }
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }
//+------------------------------------------------------------------+
void OnTimer()
  {

   MyPrint("Time", GetCurrentTime(), 20, clrBlue, 950, 10);

   switch(Cunter_print)
     {
      case 0:
         MyPrint("ExpertName", "DataGenerator Expert is working ", 20, clrYellow, 10, 10);
         Cunter_print ++;
         break;

      case 1:
         MyPrint("ExpertName", "DataGenerator Expert is working . ", 20, clrYellow, 10, 10);
         Cunter_print ++;
         break;

      case 2:
         MyPrint("ExpertName", "DataGenerator Expert is working . . ", 20, clrYellow, 10, 10);
         Cunter_print ++;
         break;

      case 3:
         MyPrint("ExpertName", "DataGenerator Expert is working . . . ", 20, clrYellow, 10, 10);
         Cunter_print ++;
         break;

      case 4:
         MyPrint("ExpertName", "DataGenerator Expert is working . . . . ", 20, clrYellow, 10, 10);
         Cunter_print ++;
         break;

      default:
         Cunter_print = 0;
         break;
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
