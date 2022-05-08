//+------------------------------------------------------------------+
//|                                         open_sell_limt_order.mq4 |
//|                                                       Jimmy Joel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property library
#property copyright "Jimmy Joel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//| My function                                                      |
//+------------------------------------------------------------------+
int     OpenSellLimitOrder(string argSymbol, double argLotSize, double argPendingPrice, double argStopLoss, double argTakeProfit, int argSlippage, int argMagicNumber, datetime argExpiration = 0, string argComment = "Sell Limit Order")
        {
            while   (IsTradeContextBusy()) Sleep(10);
            
            //Place Buy Stop Order
            int Ticket = OrderSend(argSymbol, OP_SELLLIMIT, argLotSize, argPendingPrice, argSlippage, argStopLoss, argTakeProfit, argComment, argMagicNumber, argExpiration, clrGreen);
            
            //Error handling
            
            if  (Ticket == -1)
                {
                    Print("Open Sell Limit Order - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + " Lots: " + DoubleToString(argLotSize) + " Price: " + DoubleToString(argPendingPrice) + " Stop: " + DoubleToString(argStopLoss) + " Profit: " + DoubleToString(argTakeProfit) + " Expiration: " + TimeToString(argExpiration));
                }
            return Ticket;        
        }
//+------------------------------------------------------------------+
