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
            //Moving Average
            double FastMA = iMA(Symbol(), 0, FastMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
            double SlowMA = iMA(Symbol(), 0, SlowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
            
            
            //Calculate Lot Size
            double LotSize = CalcLotSize(DynamicLotSize, EquityPercent, StopLoss, FixedLotSize);
            LotSize = VerifyLotSize(LotSize);
     
            
            // Buy Order
            if  (LastActionTime != Time[0]) // condition to execute code once per bar
                {
                   if (FastMA > SlowMA && BuyTicket == 0) 
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
                            
                            if  (BuyStopLoss > 0)
                                {
                                    BuyStopLoss = AdjustBelowStopLevel(BuyStopLoss, PipPoint(Symbol()), StopLevelPips);
                                    
                                }
                                
                            double BuyTakeProfit = CalculateTakeProfit(OP_BUY, OpenPrice, TakeProfit, PipPoint(Symbol()));
                            
                            if  (BuyTakeProfit > 0)
                                {
                                    BuyTakeProfit = AjustAboveStopLevel(BuyTakeProfit, PipPoint(Symbol()), StopLevelPips);
                                    
                                }
                            AddStopProfit(BuyTicket, BuyStopLoss, BuyTakeProfit);
                            
                        }
                }
            //Sell Order
            if  (FastMA < SlowMA && SellTicket == 0)
                {
                    if  (BuyTicket > 0) bool closed = CloseBuyOrder(Symbol(), BuyTicket, UseSlippage);
                    
                    BuyTicket = 0;
                    
                    SellTicket = OpenSellOrder(Symbol(), LotSize, UseSlippage, MagicNumber);
                    
                    if  (SellTicket > 0 && (StopLoss > 0 || TakeProfit > 0))
                        {
                            if  (!OrderSelect(SellTicket, SELECT_BY_TICKET))  Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                            
                            double OpenPrice = OrderOpenPrice();
                            
                            double SellStopLoss = CalculateStopLoss(OP_SELL, OpenPrice, StopLoss, PipPoint(Symbol()));
                            
                            if  (SellStopLoss > 0)
                                {
                                    SellStopLoss = AjustAboveStopLevel(SellStopLoss, PipPoint(Symbol()), StopLevelPips);
                                    
                                }
                            double SellTakeProfit = CalculateTakeProfit(OP_SELL, OpenPrice, TakeProfit, PipPoint(Symbol()));
                            
                            if  (SellTakeProfit > 0)
                                {
                                    SellTakeProfit = AdjustBelowStopLevel(SellTakeProfit, PipPoint(Symbol()), StopLevelPips);
                                
                                }
                            AddStopProfit(SellTicket, SellStopLoss, SellTakeProfit);   
                        }
                }
                
                LastActionTime = Time[0]; 
                    
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