//+------------------------------------------------------------------+
//|                                                Beginners RSI.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


//RSI levels are from 0 - 100, select levels for overbought and oversold and the inputs to RSI

input int InpRSIPeriods = 14;               //RSI Periods
input ENUM_APPLIED_PRICE InpRSIPrice = PRICE_CLOSE;         //RSI Applied price

//The levels

input double InpOversoldLevel = 20.0;       //Oversold level
input double InpOverboughtLevel = 80.0;     //Overbought level

//Take profit and stop loss as exit criteria for each trade
//a simple way to exit

input double InpTakeProfit = 0.01;          //Take profit in currency value i.e 100pips
input double InpStopLoss = 0.01;            //Stop loss in currency value


//Standard inputs - you should have something like this in every EA
//
input double InpOrderSize = 0.01;               //Order size - start small
input string InpTradeComment = "Beginners RSI";              //Trade comment for information on trade
input double InpMagicNumber = 212121;               //Magic number - identifies these

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
    //Event handler called when the expert is restarted - could be for many reasons
    
    ENUM_INIT_RETCODE result = INIT_SUCCEEDED;
    
    result = CheckInput();
    if (result != INIT_SUCCEEDED) return(result);  // exit if inputs were bad
    
    //There may be other things to do here but not in this example
   

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
    
    //Event handler called for any price event, price change, new trade, many things
    static bool oversold = false;
    static bool overbought = false;
    
    if (!NewBar()) return;  //only trade on a new bar
    //
    //Perform any calculations and analysis here
    //Bar 0 is currently open, bar 1 is the most recent closed bar and bar 2 is the bar before
    double rsi = iRSI(Symbol(), Period(), InpRSIPeriods,InpRSIPrice, 1);
    
    //Get the direction of the last bar. this will just give a positive number for up and negative number for down
    
    double direction = iClose(Symbol(), Period(), 1) - iOpen(Symbol(), Period(), 1);
    
    //If rsi has crossed the midpoint then clear any old flags
    
    if (rsi>50) {
        oversold = false;
    }else if (rsi<50) {
    
        overbought = false;
    }
    //Next check if the flags should be set
    //Note not just assigning the comparison to the value. this keeps any flags already set intact
    
    if (rsi > InpOverboughtLevel) overbought = true;
    if (rsi < InpOversoldLevel)  oversold = true;
    
    //Now if there is a flag set and the bar moved in the right direction make a trade
    //Trading rules are
    //Buy if
    //    -oversold is true
    //    -rsi is greater than oversold (has come out of oversold range)
    //    -last bar was an up bar
    //Sell if
    //    -overbought is true
    //    -rsi is lower than overbought (has come out of overbought range)
    //    -last bar was a down bar
    
    int ticket = 0;
    
    if (oversold && (rsi>InpOversoldLevel) && (direction > 0)) {
    
        ticket = OrderOpen(ORDER_TYPE_BUY, InpStopLoss, InpTakeProfit);
        oversold = false;  //Reset
    }else if (overbought && (rsi<InpOverboughtLevel) && (direction<0))  {
    
        ticket = OrderOpen(ORDER_TYPE_SELL, InpStopLoss, InpTakeProfit);
        overbought = false;
    }
    return;
     
}
//+------------------------------------------------------------------+

ENUM_INIT_RETCODE CheckInput (){

    //Put some code here to check any input rules
    //I'm just going to say periods must be positive
    if (InpRSIPeriods<=0) return(INIT_PARAMETERS_INCORRECT);
    
    return(INIT_SUCCEEDED);

}
//
// true/false has the bar changed
//
bool NewBar() {

    datetime currentTime = iTime(Symbol(), Period(), 0); // Gets the opening time of bar 0
    static datetime priorTime = currentTime;  //initialized to prevent trading on the first bar after
    bool result = (currentTime!=priorTime);  //Time has changed
    priorTime   =  currentTime;              //Reset for next time
    return(result);

}

int OrderOpen(ENUM_ORDER_TYPE orderType, double stopLoss, double takeProfit) {
    int ticket;
    double openPrice;
    double stopLossPrice;
    double takeProfitPrice;
    //
    //Calculate the open price, take profit and stop loss prices based on the order type
    //
    if (orderType == ORDER_TYPE_BUY) {
    
        openPrice = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_ASK),Digits());
        //Ternary operator, because it makes things look neat
        //same as saying
        //if (stopLoss ==0) {
        //  stopLossPrice = 0.0
        //}else {
        //  stopLossPrice = NormalizeDouble(openPrice - stopLoss, Digits());
        //}
        stopLossPrice = (stopLoss==0.0)?0.0: NormalizeDouble(openPrice-stopLoss, Digits());
        takeProfit = (takeProfit==0.0) ? 0.0 : NormalizeDouble(openPrice+takeProfit, Digits());
    }else if (orderType==ORDER_TYPE_SELL) {
        openPrice = NormalizeDouble(SymbolInfoDouble(Symbol(), SYMBOL_BID), Digits());
        stopLossPrice = (stopLoss==0.0)?0.0:NormalizeDouble(openPrice+stopLoss, Digits());
        takeProfitPrice = (takeProfit==0.0)? 0.0: NormalizeDouble(openPrice-takeProfit, Digits());
    
    }else {
        //This function only works with type buy or sell
        return(-1);
    }
    ticket = OrderSend(Symbol(), orderType, InpOrderSize, openPrice, 0, stopLossPrice, takeProfitPrice, InpTradeComment, InpMagicNumber);
    
    // check return codes here if needed
    
    return(ticket);

}