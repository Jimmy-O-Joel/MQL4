//+------------------------------------------------------------------+
//|                                                     tutorial.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <stdlib.mqh>


//External variables

input bool DynamicLotSize = true;
input double EquityPercent = 2;
input double FixedLotSize = 0.1;


input double StopLoss = 50;
input double TakeProfit = 100;

input int Slippage = 5;
input int MagicNumber = 123;

input int FastMAPeriod = 10;
input int SlowMAPeriod = 20;


//Global variables
int BuyTicket;
int SellTicket;

double UsePoint;
int UseSlippage;

int ErrorCode;



//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
    
    
    
    
    
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
void OnTick(){

    // Moving averages
    double FastMA = iMA(Symbol(), 0, FastMAPeriod, 0, 0, 0, 0);
    double SlowMA = iMA(Symbol(), 0, SlowMAPeriod, 0, 0, 0, 0);
    
    // Lot size calculation
    if (DynamicLotSize == true) {
        
        double RiskAmount = AccountEquity() * (EquityPercent / 100);
        double TickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
        if (Point == 0.001 || Point == 0.00001) TickValue *= 10;
        double CalcLots = (RiskAmount / StopLoss) / TickValue;
        double LotSize = CalcLots;
    
    }else double LotSize = FixedLotSize;
    
    //Lot size verification
    if (LotSize < MarketInfo(Symbol(), MODE_MINLOT)) {
        LotSize = MarketInfo(Symbol(), MODE_MINLOT);
    } else if (LotSize > MarketInfo(Symbol(),MODE_MAXLOT)) {
    
        LotSize = MarketInfo(Symbol(), MODE_MAXLOT);
    }
    
    if (MarketInfo(Symbol(), MODE_LOTSTEP) == 0.1) {
        LotSize = NormalizeDouble(LotSize,1);
    }else LotSize = NormalizeDouble(LotSize, 2);
    
    
    //Buy Order
    if (FastMA > SlowMA && BuyTicket == 0) {
        //Close Order
        OrderSelect(SellTicket, SELECT_BY_TICKET);
        
        if (OrderCloseTime() == 0 && SellTicket > 0) {
        
            double CloseLots = OrderLots();
            
            while (IsTradeContextBusy()) Sleep(10);
            
            RefreshRates();
            
            double ClosePrice = Ask;
            
            bool Closed = OrderClose(SellTicket, CloseLots,ClosePrice, UseSlippage, Red);
            
            //Error handling
            
            if (Closed == false) {
                ErrorCode = GetLastError();
                string ErrDesc = ErrorDescription(ErrorCode);
                
                string ErrAlert = StringConcatenate("Close Sell Order - Error ", ErrorCode, ": ", ErrDesc);
                Alert(ErrAlert);
                
                string ErrLog = StringConcatenate("Ask: ", Ask, " Lots: ", LotSize, "Ticket: ", SellTicket);
                Print(ErrLog);
                
            }
        }
        // Open buy order
        while (IsTradeContextBusy()) Sleep(10);
        RefreshRates();
        
        BuyTicket = OrderSend(Symbol(), OP_BUY, LotSize, Ask, UseSlippage, 0, 0, "Buy Order", MagicNumber, 0, Green);
        
        
        //Error handling
        
        if (BuyTicket == -1) {
            ErrorCode = GetLastError();
            string ErrDesc = ErrorDescription(ErrorCode);
            string ErrAlert = StringConcatenate("Open Buy Order - Error ", ErrorCode, ": ", ErrDesc);
            Alert(ErrAlert);
            
            string ErrLog = StringConcatenate("Ask: ", Ask, " Lots: ", LotSize);
            Print(ErrLog);
        
        }
        
        // Order Modification
        else {
        
            OrderSelect(BuyTicket, SELECT_BY_TICKET);
            double OpenPrice = OrderOpenPrice();
            
            // Calculate stop level
            double StopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
            
            RefreshRates();
            double UpperStopLevel = Ask + StopLevel;
            double LowerStopLevel = Bid - StopLevel;
            
            
            double MinStop = 5 * UsePoint;
            
            // Calculate stop loss and take profit
            
            if (StopLoss > 0) double BuyStopLoss = OpenPrice - (StopLoss * UsePoint);
            if (TakeProfit > 0) double BuyTakeProfit = OpenPrice + (TakeProfit * UsePoint);
            
            
            //Verify stop loss and take profit
            
            if (BuyStopLoss > 0 && BuyStopLoss > LowerStopLevel) {
            
                BuyStopLoss = LowerStopLevel - MinStop;
            }
            if (BuyTakeProfit > 0 && BuyTakeProfit < UpperStopLevel) {
                BuyTakeProfit = UpperStopLevel + MinStop;
            }
            // Modify order
            
            if (IsTradeContextBusy()) Sleep(10);
            
            if (BuyStopLoss > 0 || BuyTakeProfit > 0) {
                bool TicketMod = OrderModify(BuyTicket, OpenPrice, BuyStopLoss, BuyTakeProfit, 0);
                
                //Error handling
                if (TicketMod == false) {
                    ErrorCode = GetLastError();
                    string ErrDesc = ErrorDescription(ErrorCode);
                    string ErrAlert = StringConcatenate("Modify Buy Order - Error", ErrorCode, ": ", ErrDesc);
                    Alert(ErrAlert);
                    
                    string ErrLog = StringConcatenate("Ask: ", Ask, "Bid: ", Bid, "Ticket: ", BuyTicket, "Stop: ", BuyStopLoss, "Profit: ", BuyTakeProfit);
                    Print(ErrLog);
                
                }
            
            }
        }
        
    SellTicket = 0;
    }
    
}
//+------------------------------------------------------------------+
