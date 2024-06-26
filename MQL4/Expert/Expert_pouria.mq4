//+------------------------------------------------------------------+
//|                                                Expert_pouria.mq4 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
static string File_list[12] = {"EURUSD60.txt","AUDCAD60.txt","AUDCHF60.txt", "AUDNZD60.txt", "AUDUSD60.txt", "EURAUD60.txt", "EURCHF60.txt", "EURGBP60.txt", "GBPUSD60.txt", "USDCAD60.txt", "USDCHF60.txt"};
static string Currency_list[12] = {"EURUSD","AUDCAD","AUDCHF", "AUDNZD", "AUDUSD", "EURAUD", "EURCHF", "EURGBP", "GBPUSD", "USDCAD", "USDCHF"};
static string An[12] = {"NAN","NAN","NAN","NAN","NAN","NAN","NAN","NAN","NAN","NAN","NAN"};
datetime lastBarTime = 0; // Variable to store the last known bar time

#import "shell32.dll"
int ShellExecuteW(int hwnd, string lpOperation, string lpFile, string lpParameters, string lpDirectory, int nShowCmd);
int FindExecutableW(string lpFile, string lpDirectory);
#import

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPrint(string objectName, string text, int fontSize, color textColor, int x, int y)
  {
   if(ObjectFind(objectName) != -1)
      ObjectDelete(objectName);
   if(!ObjectCreate(objectName, OBJ_LABEL, 0, 0, 0))
     {
      Print("Failed to create text object!");
      return;
     }
   ObjectSetString(0, objectName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, objectName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, objectName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, objectName, OBJPROP_COLOR, textColor);
   ObjectSetString(0, objectName, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, objectName, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, objectName, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(0, objectName, OBJPROP_SELECTED, 0);
   ObjectSetInteger(0, objectName, OBJPROP_ZORDER, 0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool spread_calc(string symbol, int amount)
  {
   Print(MarketInfo(symbol, MODE_SPREAD));
   if(MarketInfo(symbol, MODE_SPREAD) <= amount)
     {
      return true ;
     }
   return false ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

string folderPath = "C:\\Users\\Forex\\AppData\\Roaming\\MetaQuotes\\Terminal\\Common\\Files\\ANSWERS\\"; // مسیر فولدر مورد نظر



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_answer_file()
  {
   string batFilePath = "C://Users//Forex//AppData//Roaming//MetaQuotes//Terminal//Common//Files//Get_answer_file.bat";
   int result_get_answer = ShellExecuteW(0, "runas", "cmd.exe", "/c " + batFilePath, NULL, 0);

   /*
      if(result > 32)
        {
         Print("Get answer file successfully using ShellExecuteW.");
        }
      else
        {
         Print("Failed to get answer file using ShellExecuteW. Error code: ", result);
        }

   */
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void send_acknowledge_file()
  {
   string batFilePath = "C://Users//Forex//AppData//Roaming//MetaQuotes//Terminal//Common//Files//Send_acknowledge_file.bat";
   int result_send_acn = ShellExecuteW(0, "runas", "cmd.exe", "/c " + batFilePath, NULL, 0);

   /*
      if(result > 32)
        {
         Print("Send acknowledge file successfully using ShellExecuteW.");
        }
      else
        {
         Print("Failed to send acknowledge file using ShellExecuteW. Error code: ", result);
        }

   */
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsPositionOpen(string symbol)
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      bool x=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderSymbol()==symbol)
         return false;

     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_position()
  {
   Print("Get position function is startingz");
   for(int i = 0 ; i <= 11 ; i ++)
     {
      if(string(An[i]) == "BUY")
        {
         if(spread_calc(Currency_list[i], 15))
           {
            if(IsPositionOpen(Currency_list[i]))
              {
               if((iClose(Currency_list[i], PERIOD_H1, 1)) >= MarketInfo(Currency_list[i], MODE_ASK))
                 {
                  int ticket=OrderSend(Currency_list[i],OP_BUY,0.2,Ask,10,0,0,"Afsaneh", 60, 0,Blue);
                  if(ticket >= 1)
                     An[i] = "NAN";

                 }
              }
           }
        }
      if(string(An[i]) == "SELL")
        {
         if(spread_calc(Currency_list[i], 15))
           {
            if(IsPositionOpen(Currency_list[i]))
              {
               if((iClose(Currency_list[i], PERIOD_H1, 1)) <= MarketInfo(Currency_list[i], MODE_BID))
                 {
                  int ticket=OrderSend(Currency_list[i],OP_SELL,0.2,Bid,10,0,0,"Afsaneh", 60, 0,Red);
                  if(ticket >= 1)
                     An[i] = "NAN";
                 }
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void answer_read()
  {

   for(int i = 0; i <= 11 ; i++)
     {
      //Print(File_list[i]);
      int fileHandle = FileOpen(string(File_list[i]), FILE_TXT|FILE_COMMON|FILE_ANSI);
      An[i] = "NAN";
      //Print(fileHandle);
      if(fileHandle!=INVALID_HANDLE)
        {
         An[i] = FileReadString(fileHandle, 4);
         string An1 = FileReadString(fileHandle, 4);
         string An2 = FileReadString(fileHandle, 4);

         MyPrint("Test__"+string(i), StringSubstr(string(File_list[i]),0,6), 15, clrYellow, 60, 38*i);
         MyPrint("Test_1"+string(i), An[i], 15, clrWhiteSmoke, 200, 38*i);
         MyPrint("Test_2"+string(i), StringSubstr(An1,0,4), 15, clrWhiteSmoke, 300, 38*i);
         MyPrint("Test_3"+string(i), StringSubstr(An2,0,4), 15, clrWhiteSmoke, 400, 38*i);

        }

      FileClose(fileHandle);
     }

  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FillNAN()
  {
   datetime brokerTime = TimeCurrent();
   int currentMinute = TimeMinute(brokerTime);
   if(currentMinute >= 15)
     {
      for(int i = 0 ; i <=11 ; i++)
        {
         An[i] = "NAN";
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClrScreen()
  {
   for(int i = 0; i <= 11 ; i++)
     {

      MyPrint("Test_1"+string(i), "----", 15, clrWhiteSmoke, 200, 38*i);
      MyPrint("Test_2"+string(i), "----", 15, clrWhiteSmoke, 300, 38*i);
      MyPrint("Test_3"+string(i), "----", 15, clrWhiteSmoke, 400, 38*i);

     }


  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void del_files()
  {
   for(int i = 0 ; i <= 11 ; i ++)
     {
      FileDelete(string(File_list[i]), FILE_TXT|FILE_COMMON|FILE_ANSI);
      Print(string(File_list[i]));
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void close_all_posirtion()
  {

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      bool x=OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      bool c=OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),6,Gold);
      if(OrderType()==OP_BUY)
        {
         SendNotification("Position BUY in "+OrderSymbol()+" at time frame "+IntegerToString(OrderMagicNumber())+" successfully Closed and Profit was :"+DoubleToStr(OrderProfit(),4));
        }
      if(OrderType()==OP_SELL)
        {
         SendNotification("Position SELL in "+OrderSymbol()+" at time frame "+IntegerToString(OrderMagicNumber())+" successfully Closed and Profit was :"+DoubleToStr(OrderProfit(),4));
        }

     }

  }
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
bool check_to_get_position()
  {
   for(int i = 0 ; i <= 10 ; i++)
     {
      if(An[i] != "NAN")
         return true;
     }
   return false ;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(1);
   get_answer_file();
   if(FileIsExist(File_list[0],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[1],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[2],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[3],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[4],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[5],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[6],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[7],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[8],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[9],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[10],FILE_COMMON|FILE_TXT|FILE_ANSI)
     )
     {
      send_acknowledge_file();
      answer_read();
      get_position();
      del_files();

     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(IsNewBar())
     {
      close_all_posirtion();
      ClrScreen();
     }
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   if(check_to_get_position())
      get_position();

   get_answer_file();
   if(FileIsExist(File_list[0],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[1],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[2],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[3],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[4],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[5],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[6],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[7],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[8],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[9],FILE_COMMON|FILE_TXT|FILE_ANSI)&&
      FileIsExist(File_list[10],FILE_COMMON|FILE_TXT|FILE_ANSI)
     )
     {
      send_acknowledge_file();
      answer_read();
      get_position();
      del_files();
     }
   FillNAN();
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
