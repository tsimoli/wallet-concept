import 'package:flutter/material.dart';
import 'package:wallet_concept/op_client.dart';
import 'package:wallet_concept/transaction.dart';
import 'package:wallet_concept/transaction_item.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new WalletPage(),
    );
  }
}

class WalletPage extends StatefulWidget {
  WalletPage({Key key}) : super(key: key);

  @override
  _WalletPageState createState() => new _WalletPageState();
}

class _WalletPageState extends State<WalletPage>
    with SingleTickerProviderStateMixin {
  OPClient opClient = new OPClient();
  dynamic balance = 0.0;
  List<Transaction> transactions = [];
  Animation<double> animation;
  AnimationController controller;

  /*
      Possible account ids
      =========
      "092a39ad4cc21221ce91106c384a47f579cdd001",
      "1ef419afac38fb530ca6ccaead4a49aebdfc8f84",
      "2b83265d043212ca030f2292461ce648ca196ab7",
      "370713eabe14afc2d8648020c31575f9a38ac052", -> has transactions
      "4f5488771b0cbfce9ad04326d90226e8b667d788"
  */
  String accountId = "370713eabe14afc2d8648020c31575f9a38ac052";

  @override
  void initState() {
    super.initState();

    controller = new AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    animation = new Tween(begin: balance, end: 0.0).animate(controller);

    opClient.getBalance(accountId).then((dynamic newBalance) =>
        setState(() {
          animation = new Tween(begin: balance, end: newBalance).animate(controller);
          balance = newBalance;
          controller.forward();
        }));

    opClient.getTransactions(accountId).then((
        List<Transaction> newTransactions) =>
        setState(() {
          transactions = newTransactions;
        }));

    controller.forward();
  }

  addFunds() {
    setState(() {
      // Reset controller to animate correctly -> Maybe better way to do this?
      controller.reset();
      animation = new Tween(begin: balance, end: balance += 10.0).animate(controller);
      controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Container(
        constraints: new BoxConstraints.expand(),
        child: new Stack (
          children: <Widget>[
            _buildAppbar(context),
            _buildAppbarContents(addFunds),
            _buildBody
          ],
        ),
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
              colors: [
                new Color.fromRGBO(117, 72, 167, 1.0),
                new Color.fromRGBO(143, 90, 162, 1.0),
              ],
              begin: const FractionalOffset(-2.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              tileMode: TileMode.clamp
          ),
        ),
      ),
    );
  }

  Container get _buildBody {
    return new Container(
      margin: new EdgeInsets.only(top: 210.0),
      color: new Color.fromRGBO(219, 216, 220, 1.0),
      constraints: new BoxConstraints.expand(),
      child: new Container(
        margin: new EdgeInsets.only(top: 20.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
                margin: new EdgeInsets.only(left: 30.0),
                child: new Text("Wallet History", style: new TextStyle(
                    fontSize: 15.0, color: Colors.grey[700]))
            ),
            _buildTransactionList
          ],
        ),
      ),
    );
  }

  Widget get _buildTransactionList {
    return new Expanded(
      child: new Container(
        decoration: new BoxDecoration(
            boxShadow: [new BoxShadow(color: Colors.black, blurRadius: 1.0),],
            color: Colors.white,
            borderRadius: new BorderRadius.all(const Radius.circular(2.0))),
        margin: new EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0),
        child: new ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (BuildContext ctx, int index) {
            if (transactions[index] != null) {
              return new TransactionItem(transactions[index]);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAppbarContents(Function adddfunds) {
    Color balanceColor = balance < 0 ? Colors.red : Colors.green;

    return new AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget child) {
        print(animation.value);
        return new Container(
          margin: new EdgeInsets.only(top: 100.0),
          child: new Center(child: new Column(children: <Widget>[
            new Container(child: new Text("Available balance",
                style: new TextStyle(color: Colors.white),),
                margin: new EdgeInsets.only(bottom: 1.0),),
            new Text("${animation.value.toStringAsFixed(animation.value.truncateToDouble() == animation.value ? 0 : 2)} €",
              style: new TextStyle(color: balanceColor, fontSize: 40.0),),
            new GestureDetector(
              onTap: adddfunds,
              child: new Container(margin: new EdgeInsets.only(top: 10.0),
                  child: new Text("+ ADD MONEY", style: new TextStyle(
                      color: Colors.white, fontSize: 15.0))),
            )
          ],)
          ),
        );
      },
    );
  }

  Widget _buildAppbar(BuildContext context) {
    return new Container(
      margin: new EdgeInsets.only(
          top: MediaQuery
              .of(context)
              .padding
              .top + 20.0),
      child: new Row(children: <Widget>[
        new BackButton(color: Colors.white),
        new Text("My Wallet",
            style: new TextStyle(color: Colors.white, fontSize: 20.0)),
      ]),
    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}
