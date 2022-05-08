//+------------------------------------------------------------------+
//|                                    close_all_buy_stop_orders.mq4 |
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
void    CloseAllBuyStopOrders(string argSymbol, int argMagicNumber)
        {
            for (int i = 0; i < OrdersTotal(); i++)
                {
                    if  (!OrderSelect(i, SELECT_BY_POS))
                        {
                            Print("Order Select Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                        }
                    
                    if  (OrderMagicNumber() == argMagicNumber && OrderSymbol() == argSymbol && OrderType() == OP_BUYSTOP)
                        {
                            //Delete Order
                            
                            int CloseTicket = OrderTicket();
                            
                            while   (IsTradeContextBusy()) Sleep(10);
                            
                            bool Closed = OrderDelete(CloseTicket, clrRed);
                            
                            //Error Handling
                            
                            if  (!Closed)
                                {
                                    Print("Close All Buy Stop Orders - Error #" + IntegerToString(GetLastError()) + ": " + ErrorDescription(GetLastError()));
                                    Print("Bid: " + DoubleToString(MarketInfo(argSymbol, MODE_BID)) + " Ticket: " + IntegerToString(CloseTicket));
                                }
                            else i--;
                        }
                }
        }
//+------------------------------------------------------------------+
