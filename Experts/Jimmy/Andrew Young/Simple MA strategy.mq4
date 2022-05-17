//+------------------------------------------------------------------+
//|                                           Simple MA strategy.mq4 |
//|                                                       Jimmy Joel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Jimmy Joel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs
#include <stdlib.mqh>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

sinput  string      HINT_01             = "=================================";//External Variables
input   bool        DynamicLotSize      = true;                               //Dynamic Lot Size
input   double      EquityPercent       = 2;                                  //Equity Percentage
input   double      FixedLotSize        = 0.1;                                //Fixed Lot Size
input   int         StopLoss            = 100;                                 //Stop Loss
input   int         TakeProfit          = 50;                                //Take Profit
input   int         Slippage            = 5;                                  //Slippage
input   int         MagicNumber         = 2222;                               //Magic Number
input   int         TrailingStop        = 50;                                  //Trailing stop
input   int         MinProfit           = 20;                                 //Minimum Profit
input   string      StartTradingTime    = "08:00";                             //Start Trading Time
input   string      StopTradingTime     = "22:00";                             // StopTradingTime
input   int         BreakEvenProfit     = 20;

sinput  string      HINT_02             = "==================================";//Moving Average periods
input   int         FastMAPeriod        = 10;                                  //FastMA Period
input   int         SlowMAPeriod        = 20;                                  //SlowMA Period
input   int         StopLevelPips       = 5;                                   //Stop Level pips                                


//Global Variables

int       BuyTicket;
int       SellTicket;
double    UsePoint;
int       UseSlippage;
datetime LastActionTime = 0;
string  CurrentTime;
bool    TradingIsAllowed    =   false;


int     OnInit()
        {
            UsePoint = PipPoint(Symbol());
            UseSlippage = GetSlippage(Symbol(), Slippage);
        
            return(INIT_SUCCEEDED);
        }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void    OnTick()
        {
            //calculate the local time
            datetime time = TimeLocal();
            Print(time);
            
            //convert local time to a formatted string
            CurrentTime = TimeToString(time,TIME_MINUTES);
            Print(CurrentTime);
            
            //Moving Average
            double FastMA = iMA(Symbol(), 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
            double SlowMA = iMA(Symbol(), 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
            
            
            //Calculate Lot Size
            double LotSize = CalcLotSize(DynamicLotSize, EquityPercent, StopLoss, FixedLotSize);
            LotSize = VerifyLotSize(LotSize);
     
            
            
            if  (LastActionTime != Time[0]) // condition to execute code once per bar
                {
                    // Buy Order
                   if (FastMA > SlowMA && BuyTicket == 0 && CheckTradingTime()) 
                        {
                            if (SellTicket > 0) bool Closed = CloseSellOrder(Symbol(), SellTicket, UseSlippage);
                            SellTicket = 0;
                            
                            BuyTicket = OpenBuyOrder(Symbol(), LotSize, UseSlippage, MagicNumber);
                            
                            if  (BuyTicket > 0 && (StopLoss > 0 || TakeProfit > 0))
                                {
                                    if  (!OrderSelect(BuyTicket, SELECT_BY_TICKET))
                                        {
                                            Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                            
                                        }
                                    double OpenPrice = OrderOpenPrice();
                                    
                                    double BuyStopLoss = CalculateStopLoss(OP_BUY, OpenPrice, StopLoss, PipPoint(Symbol()));
                                    
                                    if  (BuyStopLoss > 0 && !VerifyLowerStopLevel(BuyStopLoss))
                                        {
                                            BuyStopLoss = AdjustBelowStopLevel(BuyStopLoss, PipPoint(Symbol()), StopLevelPips);
                                            
                                        }
                                        
                                    double BuyTakeProfit = CalculateTakeProfit(OP_BUY, OpenPrice, TakeProfit, PipPoint(Symbol()));
                                    
                                    if  (BuyTakeProfit > 0 && !VerifyUpperStopLevel(BuyTakeProfit))
                                        {
                                            BuyTakeProfit = AjustAboveStopLevel(BuyTakeProfit, PipPoint(Symbol()), StopLevelPips);
                                            
                                        }
                                    AddStopProfit(BuyTicket, BuyStopLoss, BuyTakeProfit);
                                    
                                    BuyTrailingStop(Symbol(), TrailingStop, MinProfit, MagicNumber, UsePoint);
                                    
                                    BuyBreakEvenStop(Symbol(), UsePoint, MagicNumber, BreakEvenProfit);
                                    
                                    
                                    
                                }
                        }
            //Sell Order
            if  (FastMA < SlowMA && SellTicket == 0 && CheckTradingTime())
                {
                    if  (BuyTicket > 0) bool closed = CloseBuyOrder(Symbol(), BuyTicket, UseSlippage);
                    
                    BuyTicket = 0;
                    
                    SellTicket = OpenSellOrder(Symbol(), LotSize, UseSlippage, MagicNumber);
                    
                    if  (SellTicket > 0 && (StopLoss > 0 || TakeProfit > 0))
                        {
                            if  (!OrderSelect(SellTicket, SELECT_BY_TICKET))  Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                            
                            double OpenPrice = OrderOpenPrice();
                            
                            double SellStopLoss = CalculateStopLoss(OP_SELL, OpenPrice, StopLoss, PipPoint(Symbol()));
                            
                            if  (SellStopLoss > 0 && !VerifyUpperStopLevel(SellStopLoss))
                                {
                                    SellStopLoss = AjustAboveStopLevel(SellStopLoss, PipPoint(Symbol()), StopLevelPips);
                                    
                                }
                            double SellTakeProfit = CalculateTakeProfit(OP_SELL, OpenPrice, TakeProfit, PipPoint(Symbol()));
                            
                            if  (SellTakeProfit > 0 && !VerifyLowerStopLevel(SellTakeProfit))
                                {
                                    SellTakeProfit = AdjustBelowStopLevel(SellTakeProfit, PipPoint(Symbol()), StopLevelPips);
                                
                                }
                            AddStopProfit(SellTicket, SellStopLoss, SellTakeProfit); 
                            
                            SellTrailingStop(Symbol(), TrailingStop, MinProfit, MagicNumber, UsePoint);
                
                            SellBreakEvenStop(Symbol(), UsePoint, MagicNumber, BreakEvenProfit);  
                        }
                }
                
                LastActionTime = Time[0]; 
                
                Comment(
                        "TradingIsAllowed = ", CheckTradingTime(), "\n",
                        "Current Time = ", CurrentTime, "\n",
                        "Start Trading Time = ", StartTradingTime, "\n",
                        "Stop Trading Time = ", StopTradingTime
                    
                    );
                
                
                                    
                }
            
            
        
        }

//+------------------------------------------------------------------+
//| My custom functions                                                      |
//+------------------------------------------------------------------+

double  PipPoint(const string currSymbol)
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
//+------------------------------------------------------------------+
int     GetSlippage(string curr, int SlippagePips)
        {
            int CalcDigits = (int)MarketInfo(curr, MODE_DIGITS);
            
            int CalcSlippage = NULL;
            if  (CalcDigits == 2 || CalcDigits == 4) CalcSlippage = SlippagePips;
            else if (CalcDigits == 3 || CalcDigits == 5) CalcSlippage = SlippagePips * 10;
            return CalcSlippage;
        }
//+------------------------------------------------------------------+
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
         
         return LotSize;
    }
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
bool    CloseSellOrder(string argSymbol, int argCloseTicket, int argSlippage)
        {
            if  (!OrderSelect(argCloseTicket,SELECT_BY_TICKET))
                {
                    Print("Order Select error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                }
            
            bool Closed = NULL;
            
            if  (OrderCloseTime() == 0)
                {
                    double CloseLots = OrderLots();
                    
                    while(IsTradeContextBusy()) Sleep(10);
                    
                    double ClosePrice = MarketInfo(argSymbol,MODE_ASK);
                    
                    Closed = OrderClose(argCloseTicket,CloseLots,ClosePrice, argSlippage,Red);
                    
                    if(Closed == false)
                        {
                        
                            Print("Close Sell Order - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                            Print("Ticket: " + IntegerToString(argCloseTicket) + " Ask: " + DoubleToString(MarketInfo(argSymbol, MODE_ASK)));
                            
                        }
                }
            return(Closed);
        }

//+------------------------------------------------------------------+
int     OpenBuyOrder(string argSymbol, double argLotSize, int argSlippage, int argMagicNumber, string argComment = "Buy Order")
        {
            while (IsTradeContextBusy()) Sleep(10);
            
            //Place Buy Order
            
            int Ticket = OrderSend(argSymbol, OP_BUY, argLotSize, MarketInfo(argSymbol, MODE_ASK), argSlippage, 0, 0, argComment, argMagicNumber, 0, clrGreen);
            
            //Error Handling
            
            if  (Ticket == -1)
                {
                    Print("Open buy Order - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + "Ask: " + DoubleToString(MarketInfo(argSymbol, MODE_ASK)) + "Lots: " + DoubleToString(argLotSize));
                }
            return Ticket;
        }
//+------------------------------------------------------------------+
double CalculateTakeProfit(int argOrderType, double entryPrice, int argTakeProfit, double argPipPoint)
{
   double takeProfit = 0;
   if(argOrderType == OP_BUY || argOrderType == OP_BUYLIMIT || argOrderType == OP_BUYSTOP)
   {
      takeProfit = entryPrice + argTakeProfit * argPipPoint;
   }
   else if (argOrderType == OP_SELL || argOrderType == OP_SELLLIMIT || argOrderType == OP_SELLSTOP)
   {
      takeProfit = entryPrice - argTakeProfit * argPipPoint;
      
   }
   return NormalizeDouble(takeProfit, Digits);
}
//+------------------------------------------------------------------+
double CalculateStopLoss(int argOrderType, double entryPrice, int argStopLoss, double argPipPoint)
{
   double stopLoss = 0;
   if(argOrderType == OP_BUY || argOrderType == OP_BUYLIMIT || argOrderType == OP_BUYSTOP)
   {
      stopLoss = entryPrice - argStopLoss * argPipPoint;
   }
   else if (argOrderType == OP_SELL || argOrderType == OP_SELLLIMIT || argOrderType == OP_SELLSTOP)
   {
      stopLoss = entryPrice + argStopLoss * argPipPoint;
   }
   return NormalizeDouble(stopLoss, Digits);
}
//+------------------------------------------------------------------+
double  AdjustBelowStopLevel(double argAdjustPrice, double argPipPoint, int argAddPips = 0, double argOpenPrice = 0)
    {
        double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
        
        double OpenPrice;
        if  (argOpenPrice == 0) OpenPrice = MarketInfo(Symbol(), MODE_BID);
        else OpenPrice = argOpenPrice;
        
        double LowerStopLevel = OpenPrice - StopLevel;
        
        double AdjustedPrice;
        if (argAdjustPrice >= LowerStopLevel) AdjustedPrice = LowerStopLevel - (argAddPips * argPipPoint);
        else AdjustedPrice = argAdjustPrice;
        
        return AdjustedPrice;
    }
//+------------------------------------------------------------------+
double  AjustAboveStopLevel(double argAdjustPrice, double argPipPoint, int argAddPips = 0, double argOpenPrice = 0)
    {
        double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
        
        double OpenPrice; 
        
        if (argOpenPrice == 0) OpenPrice = MarketInfo(Symbol(), MODE_ASK);
        else OpenPrice = argOpenPrice;
        
        double UpperStopLevel = OpenPrice + StopLevel;
        
        double AdjustedPrice;
        
        if (argAdjustPrice <= UpperStopLevel) AdjustedPrice = UpperStopLevel + (argAddPips * argPipPoint);
        
        else AdjustedPrice = argAdjustPrice;
        
        return AdjustedPrice;
    }
//+------------------------------------------------------------------+
bool    AddStopProfit(int argTicket, double argStopLoss, double argTakeProfit)
        {
            if  (argStopLoss == 0 && argTakeProfit == 0) return false;
            
            
            if  (OrderSelect(argTicket, SELECT_BY_TICKET) == false)
                {
                    Print("Order select returned the error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                }
            
            double OpenPrice = OrderOpenPrice();
            
            while   (IsTradeContextBusy()) Sleep(10);
            
            //Modify Order
            
            bool TicketMod = OrderModify(argTicket, OpenPrice, argStopLoss, argTakeProfit, 0);
            
            //Error handling 
            
            if  (TicketMod == false)
                {
                    Print("Add Stop/Profit Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                }
                
             return TicketMod;   
        }
//+------------------------------------------------------------------+
bool    CloseBuyOrder(string argSymbol, int argCloseTicket, int argSlippage)
        {
            if  (!OrderSelect(argCloseTicket,SELECT_BY_TICKET))
                {
                    Print("Order Select error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                }
            
            bool Closed = NULL;
            
            if  (OrderCloseTime() == 0)
                {
                    double CloseLots = OrderLots();
                    
                    while(IsTradeContextBusy()) Sleep(10);
                    
                    double ClosePrice = MarketInfo(argSymbol,MODE_BID);
                    
                    Closed = OrderClose(argCloseTicket,CloseLots,ClosePrice, argSlippage,clrGreen);
                    
                    if(Closed == false)
                        {
                        
                            Print("Close Buy Order - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                            Print("Ticket: " + IntegerToString(argCloseTicket) + " Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)));
                            
                        }
                }
            return(Closed);
        }

//+------------------------------------------------------------------+
int     OpenSellOrder(string argSymbol, double argLotSize, int argSlippage, int argMagicNumber, string argComment = "Sell Order")
        {
            while (IsTradeContextBusy()) Sleep(10);
            
            //Place Sell Order
            
            int Ticket = OrderSend(argSymbol, OP_SELL, argLotSize, MarketInfo(argSymbol, MODE_BID), argSlippage, 0, 0, argComment, argMagicNumber, 0, clrRed);
            
            //Error Handling
            
            if  (Ticket == -1)
                {
                    Print("Open sell Order - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + "Ask: " + DoubleToString(MarketInfo(argSymbol, MODE_ASK)) + "Lots: " + DoubleToString(argLotSize));
                }
            return Ticket;
        }
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
bool    CheckTradingTime()
        {
            if  (StringSubstr(CurrentTime, 0, 5) == StartTradingTime)
                {
                    TradingIsAllowed = true;
                }
            if  (StringSubstr(CurrentTime, 0, 5) == StopTradingTime) TradingIsAllowed = false;
            
            return TradingIsAllowed; 
            
            
            
        }
//+------------------------------------------------------------------+
void    BuyTrailingStop(string argSymbol, int argTrailingStop, int argMinProfit, int argMagicNumber, double argPipPoint)
        {
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if  (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                        }
                    //Calculate Max Stop and Min Profit
                    
                    double MaxStopLoss = MarketInfo(argSymbol, MODE_BID) - (argTrailingStop * argPipPoint);
                    
                    MaxStopLoss = NormalizeDouble(MaxStopLoss, (int)MarketInfo(argSymbol, MODE_DIGITS));
                    
                    double CurrStop = NormalizeDouble(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS));
                    
                    double PipsProfit = MarketInfo(argSymbol, MODE_BID) - OrderOpenPrice();
                    double MinimProfit = argMinProfit * argPipPoint;
                    
                    //Modify Stop
                    
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUY && CurrStop < MaxStopLoss && PipsProfit >= MinimProfit)
                        {
                            bool Trailed = OrderModify(OrderTicket(), OrderOpenPrice(), MaxStopLoss, OrderTakeProfit(), 0);
                            
                            if  (!Trailed)
                                {
                                    Print("Buy Trailing Stop - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + " Ticket: " + IntegerToString(OrderTicket()) + " Stop: " + DoubleToString(OrderStopLoss()) + " Trail: " + DoubleToString(MaxStopLoss));
                                }
                        }
                }
        }
//+------------------------------------------------------------------+
void    SellTrailingStop(string argSymbol, int argTrailingStop, int argMinProfit, int argMagicNumber, double argPipPoint)
        {
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if  (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                        }
                    //Calculate Max Stop and Min Profit
                    
                    double MaxStopLoss = MarketInfo(argSymbol, MODE_ASK) + (argTrailingStop * argPipPoint);
                    
                    MaxStopLoss = NormalizeDouble(MaxStopLoss, (int)MarketInfo(argSymbol, MODE_DIGITS));
                    
                    double CurrStop = NormalizeDouble(OrderStopLoss(), (int)MarketInfo(OrderSymbol(), MODE_DIGITS));
                    
                    double PipsProfit = OrderOpenPrice() + MarketInfo(argSymbol, MODE_ASK);
                    double MinimProfit = argMinProfit * argPipPoint;
                    
                    //Modify Stop
                    
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELL && (CurrStop > MaxStopLoss || CurrStop == 0 ) && PipsProfit >= MinimProfit)
                        {
                            bool Trailed = OrderModify(OrderTicket(), OrderOpenPrice(), MaxStopLoss, OrderTakeProfit(), 0);
                            
                            if  (!Trailed)
                                {
                                    Print("Sell Trailing Stop - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + " Ticket: " + IntegerToString(OrderTicket()) + " Stop: " + DoubleToString(OrderStopLoss()) + " Trail: " + DoubleToString(MaxStopLoss));
                                }
                        }
                }
        }
//+------------------------------------------------------------------+
void    BuyBreakEvenStop(string argSymbol, double argPipPoint, int argMagicNumber, int argBreakEvenProfit)
        {
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if  (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                        }
                        
                    RefreshRates();
                    
                    double PipsProfit = MarketInfo(argSymbol, MODE_BID) - OrderOpenPrice();
                    double MinimProfit = argBreakEvenProfit * argPipPoint;
                    
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUY && PipsProfit >= MinimProfit && OrderOpenPrice() != OrderStopLoss())
                        {
                            bool BreakEven = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrRed);
                            
                            if  (!BreakEven)
                                {
                                    Print("Buy Break Even - Error " + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                    Print("Bid: ", Bid, ", Ask: ", Ask, ", Stop: ", OrderStopLoss(), ", Break: ", MinProfit);
                                }
                        }
                }
        }
//+------------------------------------------------------------------+
void    SellBreakEvenStop(string argSymbol, double argPipPoint, int argMagicNumber, int argBreakEvenProfit)
        {
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if  (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                        }
                        
                    RefreshRates();
                    
                    double PipsProfit = OrderOpenPrice() - MarketInfo(argSymbol, MODE_ASK);
                    double MinimProfit = argBreakEvenProfit * argPipPoint;
                    
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELL && PipsProfit >= MinimProfit && OrderOpenPrice() != OrderStopLoss())
                        {
                            bool BreakEven = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrRed);
                            
                            if  (!BreakEven)
                                {
                                    Print("Sell Break Even - Error " + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                    Print("Bid: ", Bid, ", Ask: ", Ask, ", Stop: ", OrderStopLoss(), ", Break: ", MinProfit);
                                }
                        }
                }
        }
//+------------------------------------------------------------------+