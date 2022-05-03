//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                                                       Jimmy Joel |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Jimmy Joel"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs

#include <CustomFunction.mqh>
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

input int slowMAPeriod = 20;
input int fastMAPeriod = 14;
input int stopLossPips = 40;
input int takeProfitPips = 40;
input double maxRiskPerc = 0.02;
input int maxLossInPips = 50;
input int magicNumber = 7777;

 
int OnInit() {

    Alert("EA started Successfully!");

    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
    Alert("EA closed successfully!");
   
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void    OnTick() 
        {

            double slowMA[2];
            double fastMA[2];
            
            slowMA[0] = iMA(Symbol(), PERIOD_CURRENT, slowMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 1); //current slow ma
            slowMA[1] = iMA(Symbol(), 0, slowMAPeriod, 0, 0, 0, 2); //prev slow ma
            
            fastMA[0] = iMA(Symbol(), 0, fastMAPeriod, 0, 0, 0, 1); //current fast ma
            fastMA[1] = iMA(Symbol(), 0, fastMAPeriod, 0, 0, 0, 2); //prev fast ma
            
            
            if (IsTradingAllowed()){
            
            if (!CheckIfOpenOrdersByMagicNumber(magicNumber)){
            
                if (fastMA[0] > slowMA[0] && fastMA[1] < slowMA[1]) {
                    //send a buy order
                    double stopLoss = CalculateStopLoss(OP_BUY, Ask, stopLossPips);
                    double takeProfit = CalculateTakeProfit(OP_BUY, Ask, takeProfitPips);
                    double lotSize = CalcLotSize(true, 2, stopLoss);
                    
                    Comment("Stop Loss = ", DoubleToString(stopLoss,Digits), "\nTake Profit = ", DoubleToString(takeProfit, Digits));
                    
                    if (!IsTradingAllowed()) {
                        Print("Trade not allowed, check autotrading");
                    } else {
                        OpenBuyOrder(lotSize, stopLoss, takeProfit, magicNumber);
                    }
                }else if (fastMA[0] < slowMA[0] && fastMA[1] > slowMA[1]) {
                    //send a sell order
                    double stopLoss = CalculateStopLoss(OP_SELL, Bid, stopLossPips);
                    double takeProfit = CalculateTakeProfit(OP_SELL, Bid, takeProfitPips);
                    double lotSize = CalcLotSize(true, 2, stopLoss);
                    
                    Comment("Stop Loss = ", DoubleToString(stopLoss,Digits), "\nTake Profit = ", DoubleToString(takeProfit, Digits));
                    if (!IsTradingAllowed()) {
                    
                        Print("Trade not completed, check Autotrading");
                    } else {
                        OpenSellOrder(lotSize, stopLoss, takeProfit, magicNumber);
                    }
                
                }
            }
            
                
                
            }
            
    
   
        }

//+------------------------------------------------------------------+
