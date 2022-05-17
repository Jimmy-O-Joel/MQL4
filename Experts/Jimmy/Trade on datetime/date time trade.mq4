//+------------------------------------------------------------------+
//|                                              date time trade.mq4 |
//|                                                       Jimmy Joel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Jimmy Joel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <stdlib.mqh>

sinput          string                                  HINT01                  =   "===================================="; // External variables
input            string                                  StartTradingTime     =   "08:00";    //Start trading time
input            string                                  StopTradingTime      =   "22:00";    //stop trading time
input            int                                       Slippage                 =   5;
input            int                                       EquityPercent         =   2;
input            int                                       MagicNumber          =   777;
input            double                                 FixedLotSize          =   0.1;
input            bool                                     DynamicLotSize     =   true;
input            ENUM_ORDER_TYPE          OpenPosition          =   OP_SELL;
input            int                                        StopLoss                =   100;
input            int                                        TakeProfit                =   50;                               


sinput          string                                    HINT02                   =   "==================================="; //Break Even and Trailing stop
input            int                                        BreakEven               =   20;
input            int                                        TrailingStop             =   20;
input            bool                                      AllowBE                  =    true;
input            bool                                      AllowTrailStop          =    true;


int     StopLevelPips       =   5;
double    UsePoint;
int       UseSlippage;
datetime LastActionTime = 0;


string  CurrentTime;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
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

   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void    OnTick()
        {
            bool    TradingIsAllowed    =   false;
            //calculate the local time
            datetime time = TimeLocal();
            Print(time);
            
            //convert local time to a formatted string
            CurrentTime = TimeToString(time,TIME_MINUTES);
            Print(CurrentTime);
            if  (LastActionTime != Time[0]) // condition to execute code once per bar
                {
                    if  (StringSubstr(CurrentTime, 0, 5) == StartTradingTime && OpenOrdersThisPair(Symbol()) == 0 &&  StringSubstr(CurrentTime, 0, 5) != StopTradingTime)
                {
                    double LotSize = CalcLotSize(DynamicLotSize, EquityPercent, StopLoss, FixedLotSize);
                    LotSize = VerifyLotSize(LotSize);
                    
                    //Place a buy order
                    
                    if (OpenPosition == OP_BUY)
                        {
                            int BuyTicket = OpenBuyOrder(Symbol(), LotSize, Slippage, MagicNumber);
                    
                            if  (BuyTicket > 0 && (TakeProfit > 0 || StopLoss > 0))
                                {
                                    if  (!OrderSelect(BuyTicket, SELECT_BY_TICKET))
                                        {
                                            Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                            
                                        }
                                        
                                    //Calculate take profit and verify and adjust stop levels   
                                     double BuyTakeProfit = CalculateTakeProfit(OP_BUY, OrderOpenPrice(), TakeProfit, UsePoint);
                                     
                                     if (BuyTakeProfit > 0 && !VerifyUpperStopLevel(BuyTakeProfit))
                                        {
                                            BuyTakeProfit = AdjustAboveStopLevel(BuyTakeProfit, UsePoint, StopLevelPips);
                                        }
                                        
                                    //Calculate StopLoss, Verify and adjust stopLevels
                                        
                                    double BuyStopLoss = CalculateStopLoss(OP_BUY, OrderOpenPrice(), StopLoss, UsePoint);
                                    
                                    if  (BuyStopLoss > 0 && !VerifyLowerStopLevel(BuyStopLoss))
                                        {
                                            BuyStopLoss = AdjustBelowStopLevel(BuyStopLoss, UsePoint,StopLevelPips);
                                        }
                                        
                                    //Function to add takeprofit and stoploss    
                                    AddStopProfit(BuyTicket, BuyStopLoss, BuyTakeProfit); 
                                    
                                                                             
                                }
                               // BuyBreakEvenStop(Symbol(), UsePoint, MagicNumber, BreakEvenProfit);
                               // BuyTrailingStop(Symbol(), TrailingStop, MinProfit, MagicNumber, UsePoint);
                                                        
                        }
                        
                    //Open market Sell Order
                    if (OpenPosition == OP_SELL)
                        {
                            int SellTicket = OpenSellOrder(Symbol(), LotSize, Slippage, MagicNumber);
                    
                            if  (SellTicket > 0 && (TakeProfit > 0 || StopLoss > 0))
                                {
                                    if  (!OrderSelect(SellTicket, SELECT_BY_TICKET))
                                        {
                                            Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                            
                                        }
                                        
                                    //Calculate take profit and verify and adjust stop levels   
                                     double SellTakeProfit = CalculateTakeProfit(OP_SELL, OrderOpenPrice(), TakeProfit, UsePoint);
                                     
                                     if (SellTakeProfit > 0 && !VerifyLowerStopLevel(SellTakeProfit))
                                        {
                                            SellTakeProfit = AdjustBelowStopLevel(SellTakeProfit, UsePoint, StopLevelPips);
                                        }
                                        
                                    //Calculate StopLoss, Verify and adjust stopLevels
                                        
                                    double SellStopLoss = CalculateStopLoss(OP_SELL, OrderOpenPrice(), StopLoss, UsePoint);
                                    
                                    if  (SellStopLoss > 0 && !VerifyUpperStopLevel(SellStopLoss))
                                        {
                                            SellStopLoss = AdjustAboveStopLevel(SellStopLoss, UsePoint,StopLevelPips);
                                        }
                                        
                                    //Function to add takeprofit and stoploss    
                                    AddStopProfit(SellTicket, SellStopLoss, SellTakeProfit); 
                                    
                                                   
                                          
                                }
                                //SellBreakEvenStop(Symbol(), UsePoint, MagicNumber, BreakEvenProfit);
                               // SellTrailingStop(Symbol(), TrailingStop, MinProfit, MagicNumber, UsePoint);
                            
                        }    
                    
                    
                                
                    LastActionTime = Time[0];  
                                    
                                        
                    Comment(
                        "Start Trading Time = ", StartTradingTime, "\n",
                        "Stop Trading Time = ", StopTradingTime
                    
                    );                 
                    
                }   
                }
                
                if  (AllowTrailStop)   TrailingStop(Symbol(), MagicNumber, UsePoint, TrailingStop);
                
                if (AllowBE)    BreakEven(Symbol(), MagicNumber, BreakEven, UsePoint);
                
                if  ( StringSubstr(CurrentTime, 0, 5) == StopTradingTime)
                    {
                        CloseAllBuyOrders(Symbol(), MagicNumber, UseSlippage);
                        CloseAllSellOrders(Symbol(), MagicNumber, UseSlippage);
                    }
            
        
        
        }
//+------------------------------------------------------------------+
//| My custom functions                                                      |
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
double  AdjustAboveStopLevel(double argAdjustPrice, double argPipPoint, int argAddPips = 0, double argOpenPrice = 0)
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
int     OpenOrdersThisPair(string argSymbol)
        {
            int Total = 0;
            
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if  (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error # ",GetLastError(),": ", ErrorDescription(GetLastError()));
                        }
                    if  (OrderSymbol() == argSymbol)
                        {
                            Total++;
                        }    
                }
            return Total;    
        }
//+------------------------------------------------------------------+
void    TrailingStop(string argSymbol, int argMagicNumber, double argPipPoint, int argTrailingStop)
        {
            //Buy Order Section
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #", GetLastError(), ": ", ErrorDescription(GetLastError()));
                        }
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUY)
                        if  (Bid - OrderOpenPrice() > argTrailingStop * argPipPoint)
                            if  (OrderStopLoss() < Bid - argTrailingStop * argPipPoint)
                                {
                                    bool Mod =  OrderModify(OrderTicket(), OrderOpenPrice(), Bid - (argTrailingStop*argPipPoint), OrderTakeProfit(), 0, clrNONE); 
                                    
                                    if  (!Mod)
                                            {
                                                Print("Order Modify Error # ", GetLastError(), ": ", ErrorDescription(GetLastError()));
                                            }
                                }   
                }
                
            //Sell Order Section
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #", GetLastError(), ": ", ErrorDescription(GetLastError()));
                        }
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELL)
                        if  (OrderOpenPrice() - Ask > argTrailingStop * argPipPoint)
                            if  (OrderStopLoss() > Ask + argTrailingStop * argPipPoint || OrderStopLoss() == 0)
                                {
                                    bool Mod =  OrderModify(OrderTicket(), OrderOpenPrice(), Ask + (argTrailingStop*argPipPoint), OrderTakeProfit(), 0, clrNONE); 
                                     
                                    if  (!Mod)
                                            {
                                                Print("Order Modify Error # ", GetLastError(), ": ", ErrorDescription(GetLastError()));
                                            }
                                }
                                 
                }    
        }
//+------------------------------------------------------------------+
void    BreakEven(string argSymbol, int argMagicNumber, int argBreakEven, double argPipPoint)
         {
                //buy order
                for (int i = 0; i < OrdersTotal(); i++)
                    {
                         if (!OrderSelect(i, SELECT_BY_POS))
                            {
                                Print("Order Select Error #", GetLastError(), ": ", ErrorDescription(GetLastError()));
                            }
                        if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUY)
                            if  (OrderOpenPrice() + argBreakEven * argPipPoint <= Bid)
                                if (OrderOpenPrice() > OrderStopLoss())
                                    {
                                        bool Mod = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrNONE);    
                                    
                                        if  (!Mod)
                                            {
                                                Print("Order Modify Error # ", GetLastError(), ": ", ErrorDescription(GetLastError()));
                                            }
                                        
                                    }
                                    
                    }
                //Sell order
                for (int i = 0; i < OrdersTotal(); i++)
                    {
                        if (!OrderSelect(i, SELECT_BY_POS))
                            {
                                Print("Order Select Error #", GetLastError(), ": ", ErrorDescription(GetLastError()));
                            }
                        if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELL)
                            if  (OrderOpenPrice() - argBreakEven * argPipPoint >= Ask)
                                if  (OrderOpenPrice() < OrderStopLoss() || OrderStopLoss() == 0)  
                                    {  
                                        bool Mod = OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice(), OrderTakeProfit(), 0, clrNONE);
                                        
                                        if  (!Mod)
                                            {
                                                Print("Order Modify Error # ", GetLastError(), ": ", ErrorDescription(GetLastError()));
                                            }
                                    }
                        
                    }
                        
         }
//+------------------------------------------------------------------+
void    CloseAllSellOrders(string argSymbol, int argMagicNumber, int argSlippage)
        {
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if  (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                        }
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_SELL)
                        {
                            //Close Order
                            int CloseTicket = OrderTicket();
                            double CloseLots = OrderLots();
                            
                            while   (IsTradeContextBusy()) Sleep(10);
                            
                            double ClosePrice = MarketInfo(argSymbol, MODE_ASK);
                            
                            bool Closed = OrderClose(CloseTicket, CloseLots, ClosePrice, argSlippage, clrRed);
                            
                            //Error handling
                            
                            if  (!Closed)
                                {
                                    Print("Close All Sell Orders - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + " Ticket: " + IntegerToString(CloseTicket) + " Price: " + DoubleToString(ClosePrice));
                                }
                            else i--;
                        }
                }
        }
//+------------------------------------------------------------------+
void    CloseAllBuyOrders(string argSymbol, int argMagicNumber, int argSlippage)
        {
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if  (!OrderSelect(i, SELECT_BY_POS))
                    {
                        Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                        
                    }
                    
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUY)
                        {
                            // Close Order
                            int CloseTicket = OrderTicket();
                            double CloseLots = OrderLots();
                            
                            while   (IsTradeContextBusy()) Sleep(10);
                            
                            double ClosePrice = MarketInfo(argSymbol, MODE_BID);
                            
                            bool closed = OrderClose(CloseTicket, CloseLots, ClosePrice, argSlippage, Red);
                            
                            //Error handling
                            
                            if  (!closed)
                                {
                                    Print("Close All Buy Orders - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + " Ticket: " + IntegerToString(CloseTicket) + " Price: " + DoubleToString(ClosePrice));
                                }
                            else i--;  
                        }
                }
        }
//+------------------------------------------------------------------+
