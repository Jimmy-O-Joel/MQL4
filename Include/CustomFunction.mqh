//+------------------------------------------------------------------+
//|                                               CustomFunction.mqh |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


double CalculateTakeProfit(int argOrderType, double entryPrice, int pips)
{
   double takeProfit = 0;
   if(argOrderType == OP_BUY || argOrderType == OP_BUYLIMIT || argOrderType == OP_BUYSTOP)
   {
      takeProfit = entryPrice + pips * pipPoint(Symbol());
   }
   else if (argOrderType == OP_SELL || argOrderType == OP_SELLLIMIT || argOrderType == OP_SELLSTOP)
   {
      takeProfit = entryPrice - pips * pipPoint(Symbol());
      
   }
   return NormalizeDouble(takeProfit, Digits);
}

double CalculateStopLoss(int argOrderType, double entryPrice, int pips)
{
   double stopLoss = 0;
   if(argOrderType == OP_BUY || argOrderType == OP_BUYLIMIT || argOrderType == OP_BUYSTOP)
   {
      stopLoss = entryPrice - pips * pipPoint(Symbol());
   }
   else if (argOrderType == OP_SELL || argOrderType == OP_SELLLIMIT || argOrderType == OP_SELLSTOP)
   {
      stopLoss = entryPrice + pips * pipPoint(Symbol());
   }
   return NormalizeDouble(stopLoss, Digits);
}




double GetPipValue()
{
   if(_Digits >=4)
   {
      return 0.0001;
   }
   else
   {
      return 0.01;
   }
}


void DayOfWeekAlert()
{

   Alert("");
   
   int dayOfWeek = DayOfWeek();
   
   switch (dayOfWeek)
   {
      case 1 : Alert("We are Monday. Let's try to enter new trades"); break;
      case 2 : Alert("We are tuesday. Let's try to enter new trades or close existing trades");break;
      case 3 : Alert("We are wednesday. Let's try to enter new trades or close existing trades");break;
      case 4 : Alert("We are thursday. Let's try to enter new trades or close existing trades");break;
      case 5 : Alert("We are friday. Close existing trades");break;
      case 6 : Alert("It's the weekend. No Trading.");break;
      case 0 : Alert("It's the weekend. No Trading.");break;
      default : Alert("Error. No such day in the week.");
   }
}


double GetStopLossPrice(bool bIsLongPosition, double entryPrice, int argMaxLossInPips)
{
   double stopLossPrice;
   if (bIsLongPosition)
   {
      stopLossPrice = entryPrice - argMaxLossInPips * 0.0001;
   }
   else
   {
      stopLossPrice = entryPrice + argMaxLossInPips * 0.0001;
   }
   return stopLossPrice;
}


bool IsTradingAllowed()
{
   if(!IsTradeAllowed())
   {
      Print("Expert Advisor is NOT Allowed to Trade. Check AutoTrading.");
      return false;
   }
   
   if(!IsTradeAllowed(Symbol(), TimeCurrent()))
   {
      Print("Trading NOT Allowed for specific Symbol and Time");
      return false;
   }
   
   return true;
}
  
  
double OptimalLotSize(double maxRiskPrc, int argMaxLossInPips)
{

  double accEquity = AccountEquity();
  Print("accEquity: " + DoubleToString(accEquity,2));
  
  double lotSize = MarketInfo(NULL,MODE_LOTSIZE);
  Print("lotSize: " + DoubleToString(lotSize,2));
  
  double tickValue = MarketInfo(NULL,MODE_TICKVALUE);
  
  if(Digits <= 3)
  {
   tickValue = tickValue /100;
  }
  
  Print("tickValue: "+ DoubleToString(tickValue,2));
  
  double maxLossDollar = accEquity * maxRiskPrc;
  Print("maxLossDollar: " + DoubleToString(maxLossDollar,2));
  
  double maxLossInQuoteCurr = maxLossDollar / tickValue;
  Print("maxLossInQuoteCurr: " + DoubleToString(maxLossInQuoteCurr,2));
  
  double optimalLotSize = NormalizeDouble(maxLossInQuoteCurr /(argMaxLossInPips * GetPipValue())/lotSize,2);
  
  return optimalLotSize;
 
}


double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
{
   return OptimalLotSize(maxRiskPrc,int(MathAbs(entryPrice - stopLoss)/GetPipValue()));
}



bool CheckIfOpenOrdersByMagicNB(int magicNB)
{
   int openOrders = OrdersTotal();
   
   for(int i = 0; i < openOrders; i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber() == magicNB) 
         {
            return true;
         }  
      }
   }
   return false;
}

int OpenBuyOrder(double argLotSize, double argStopLoss, double argTakeprofit, int argMagicNumber, string argComment = "Buy Order") {

    int Ticket = OrderSend(Symbol(), OP_BUY, argLotSize, Ask, 1, argStopLoss, argTakeprofit, argComment, argMagicNumber);
    
    if (Ticket < 0) {
        Print("Order not sent because of ", ErrorDescription(GetLastError()));
     }
     return Ticket;
    
}

int OpenSellOrder(double argLotSize, double argStopLoss, double argTakeprofit, int argMagicNumber, string argComment = "Sell Order") {

    int Ticket = OrderSend(Symbol(), OP_SELL, argLotSize, Bid, 1, argStopLoss, argTakeprofit, argComment, argMagicNumber);
    
    if (Ticket < 0) {
        Print("Order not sent because of ", ErrorDescription(GetLastError()));
    }
    return Ticket;
}



bool    VerifyUpperStopLevel(double argVerifyPrice, double argOpenPrice = 0) 
    {
        double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
        
        double OpenPrice;
        
        if (argOpenPrice == 0) OpenPrice = MarketInfo(Symbol(), MODE_ASK);
        else OpenPrice = argOpenPrice; //Use this when verifying stoploss and take profit prices for pending orders
        
        double UpperStopLevel = OpenPrice + StopLevel;
        
        bool StopVerify;
        
        if (argVerifyPrice > UpperStopLevel) StopVerify = true;
        else StopVerify = false;
        
        return StopVerify; 
        
    }

bool    VerifyLowerStopLevel(double argVerifyPrice, double argOpenPrice = 0)
    {
        double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
        
        double OpenPrice;
        if (argOpenPrice == 0) OpenPrice = MarketInfo(Symbol(), MODE_BID);
        else OpenPrice = argOpenPrice;
        
        double LowerStopLevel = OpenPrice - StopLevel;
        
        bool StopVerify;
        if (argVerifyPrice < LowerStopLevel) StopVerify = true;
        else StopVerify = false;
        
        return StopVerify;
    }


    

double  AjustAboveStopLevel(double argAdjustPrice, int argAddPips = 0, double argOpenPrice = 0)
    {
        double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
        
        double OpenPrice; 
        
        if (argOpenPrice == 0) OpenPrice = MarketInfo(Symbol(), MODE_ASK);
        else OpenPrice = argOpenPrice;
        
        double UpperStopLevel = OpenPrice + StopLevel;
        
        double AdjustedPrice;
        
        if (argAdjustPrice <= UpperStopLevel) AdjustedPrice = UpperStopLevel + (argAddPips * GetPipValue());
        
        else AdjustedPrice = argAdjustPrice;
        
        return AdjustedPrice;
    }


double  AdjustBelowStopLevel(double argAdjustPrice, int argAddPips = 0, double argOpenPrice = 0)
    {
        double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
        
        double OpenPrice;
        if  (argOpenPrice == 0) OpenPrice = MarketInfo(Symbol(), MODE_BID);
        else OpenPrice = argOpenPrice;
        
        double LowerStopLevel = OpenPrice - StopLevel;
        
        double AdjustedPrice;
        if (argAdjustPrice >= LowerStopLevel) AdjustedPrice = LowerStopLevel - (argAddPips * GetPipValue());
        else AdjustedPrice = argAdjustPrice;
        
        return AdjustedPrice;
    }
    
    
double  CalcLotSize(bool argDynamicLotSize, double argEquityPercent, double argStopLoss, double argFixedLotSize=0)
    {
        double LotSize;
        if  (argDynamicLotSize == true && argStopLoss > 0)
            {
                double RiskAmount = AccountEquity() * (argEquityPercent / 100);
                double TickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
                
                if  (Point == 0.001 || Point == 0.00001) TickValue *= 10;
                
                LotSize = (RiskAmount / argStopLoss) / TickValue;
            }
         else  LotSize = argFixedLotSize;
         
         return VerifyLotSize(LotSize);
    }
    
double  VerifyLotSize(double argLotSize)
    {
        if  (argLotSize < MarketInfo(Symbol(), MODE_MINLOT))
            {
                argLotSize = MarketInfo(Symbol(), MODE_MINLOT);
            }
        else if (argLotSize > MarketInfo(Symbol(), MODE_MAXLOT))
            {
                argLotSize = MarketInfo(Symbol(), MODE_MAXLOT);
            }
            
        if  (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1) {
            argLotSize = NormalizeDouble(argLotSize,1);
        }
        else argLotSize = NormalizeDouble(argLotSize,2);
        
        return argLotSize;
    }
    
    
double  pipPoint(const string currSymbol)
        {
                double bid = SymbolInfoDouble(currSymbol, SYMBOL_BID);
                int digits = (int)SymbolInfoInteger(currSymbol, SYMBOL_DIGITS);
                double points = SymbolInfoDouble(currSymbol, SYMBOL_POINT);
                 
                if (StringFind(currSymbol, "XAU") > -1 || StringFind(currSymbol, "xau") > -1 || StringFind(currSymbol, "GOLD") > -1) return points; //Gold
                if (digits <= 1) points = 1; //CFD & Index
                if (digits == 4 || digits == 5) points = 0.0001;
                if ((digits == 2 || digits == 3) && bid > 1000) points = 1;
                if ((digits == 2 || digits == 3) && bid < 1000) points = 0.01;
                
                return points;
        }