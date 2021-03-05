//+------------------------------------------------------------------+
//|                                  USDJPYGoodMorningAsiaSystem.mq4 |
//|                      Copyright 2021, Forex Expert Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, KKU Forex Expert Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input double lot = 0.01; // Lot
input int slippage = 3; // Slippage
string comment = "GoodMorningAsiaSystem";
input int close_order_spread = 20; // Max Execute Order Spread
int order_ticket = 0;
string symbol = Symbol();

void OnTick(){
    bool is_open_new_order = true; // Check Is Order Already Exists (Same Symbol, Same System and Same Day)
    
    // Check Previous D1 Candlestick //
    double close_price = iClose(symbol,PERIOD_D1,1);
    double open_price = iOpen(symbol,PERIOD_D1,1);
    string close_order_list = "";     
   
    for(int i = 0; i < OrdersTotal(); i++){
      if(OrderSelect(i, SELECT_BY_POS)){
        if(OrderSymbol() == symbol && OrderComment() == comment){
          if(TimeToStr(OrderOpenTime(),TIME_DATE)==TimeToStr(TimeCurrent(),TIME_DATE)){
            is_open_new_order = false;
          }else{
            // Check Is Order Previous Shold Close Or Not
            if(close_price > open_price){
              if(OrderType()==OP_SELL){
                close_order_list += (string)OrderTicket()+",";
              }
            }else{
              if(OrderType()==OP_BUY){
                close_order_list += (string)OrderTicket()+",";
              }        
            }
          }
        }
      }
    }
   
    // Loop For Close Order List //
    string order_list_result[];
    ushort u_sep = StringGetCharacter(",",0);
    int total_order_list = StringSplit(close_order_list,u_sep,order_list_result);
    
    for(int i=0;i<total_order_list-1;i++){
      if(OrderSelect((int)order_list_result[i],SELECT_BY_TICKET)){
        if(OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),slippage,clrNONE)){
          printf("Close Order SUCCESS (Ticket: "+(string)OrderTicket()+")");
        }else{
          printf("Close Order FAILED (Ticket: "+(string)OrderTicket()+")");
        }
      }        
    }
   
    // Open New Order //
    if(is_open_new_order ==  true){
      if(close_price > open_price){
        order_ticket = OrderSend(symbol,OP_BUY,lot,NormalizeDouble(Ask,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
      }else{
        order_ticket = OrderSend(symbol,OP_SELL,lot,NormalizeDouble(Bid,(int)MarketInfo(symbol,MODE_DIGITS)),slippage,0,0,comment,0,0,clrNONE);
      }
      
      if(order_ticket > 0){
        printf("Open Order SUCCESS (Ticket: "+(string)order_ticket+")");
      }else{
        printf("Open Order FAILED (Ticket: "+(string)order_ticket+")");
      }
    }
}