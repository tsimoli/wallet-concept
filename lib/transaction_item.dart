import 'package:flutter/material.dart';
import 'package:wallet_concept/transaction.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;

  TransactionItem(this.transaction);

  @override
  Widget build(BuildContext context) {
    var amount = transaction.amount;
    var amountColor = Colors.green;
    if (amount.toDouble() < 0) {
      amountColor = Colors.red;
    }
    return new Container(
        key: new Key(transaction.id),
        padding: new EdgeInsets.all(12.0),
        height: 75.0,
        decoration: new BoxDecoration(border: new Border(
            top: new BorderSide(width: 0.3, color: Colors.grey))),
        child: new Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                new Text("${transaction.purpose}"),
                new Text("Ref. ${transaction.id}"),
                new Text(
                  "${transaction.date}",
                  style: new TextStyle(color: Colors.grey, fontSize: 13.0),
                )
              ],
            ),
            new Text("$amount €", style: new TextStyle(color: amountColor),)
          ],
        )
    );
  }

}