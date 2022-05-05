//+------------------------------------------------------------------+
//|                                              open_sell_order.mq4 |
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
