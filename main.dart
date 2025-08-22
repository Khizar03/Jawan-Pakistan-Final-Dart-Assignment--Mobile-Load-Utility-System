import 'dart:io';

class Wallet {
  double balance = 0;

  void addBalance(double amount) {
    if (amount <= 0) {
      print("❌ Invalid amount! Must be greater than 0.");
      return;
    }
    balance += amount;
    print("✅ Rs.$amount added. Current Balance: Rs.$balance");
  }

  bool deduct(double amount) {
    if (amount > balance) {
      print("❌ Not enough balance! Current Balance: Rs.$balance");
      return false;
    }
    balance -= amount;
    return true;
  }
}

class Transaction {
  String type; // "Recharge" or "Bill"
  String detail; // mobile number or bill type
  double amount;
  DateTime date;

  Transaction(this.type, this.detail, this.amount) : date = DateTime.now();

  @override
  String toString() {
    return "$type | $detail | Rs.$amount | ${date.toLocal()}";
  }
}

class PaymentSystem {
  Wallet wallet = Wallet();
  List<Transaction> history = [];
  List<String> savedNumbers = [];
  List<String> savedBills = [];

  void rechargeMobile(String number, String operator, double amount) {
    if (!_validateNumber(number)) return;

    if (wallet.deduct(amount)) {
      history.add(Transaction("Recharge", "$operator - $number", amount));
      print(
        "📱 Recharged Rs.$amount to $operator number $number successfully!",
      );
    }
  }

  void payBill(String type, double amount) {
    if (wallet.deduct(amount)) {
      history.add(Transaction("Bill Payment", type, amount));
      print("💡 $type Bill of Rs.$amount paid successfully!");
    }
  }

  void addSavedNumber(String number) {
    if (!_validateNumber(number)) return;
    if (!savedNumbers.contains(number)) {
      savedNumbers.add(number);
      print("✅ Number $number saved for quick recharge.");
    } else {
      print("⚠️ Number already saved.");
    }
  }

  void addSavedBill(String billType) {
    if (!savedBills.contains(billType)) {
      savedBills.add(billType);
      print("✅ Bill $billType saved for quick payment.");
    } else {
      print("⚠️ Bill already saved.");
    }
  }

  void viewHistory() {
    if (history.isEmpty) {
      print("📂 No transactions found.");
    } else {
      print("📂 Transaction History:");
      history.forEach((t) => print(t));
    }
  }

  bool _validateNumber(String number) {
    if (number.length != 11 || !RegExp(r'^[0-9]+$').hasMatch(number)) {
      print("❌ Invalid number! Must be 11 digits.");
      return false;
    }
    return true;
  }
}

void main() {
  PaymentSystem system = PaymentSystem();

  while (true) {
    print("\n📌 Mobile Load & Utility Payment System:");
    print("1. Add Balance");
    print("2. Recharge Mobile");
    print("3. Pay Utility Bill");
    print("4. Save Frequent Number");
    print("5. Save Frequent Bill");
    print("6. View Transaction History");
    print("7. Exit");
    stdout.write("👉 Enter your choice: ");
    var choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        stdout.write("Enter amount to add: ");
        double amount = double.parse(stdin.readLineSync()!);
        system.wallet.addBalance(amount);
        break;

      case '2':
        stdout.write("Enter mobile number: ");
        String number = stdin.readLineSync()!;
        print("Select Operator: 1) Jazz 2) Telenor 3) Zong 4) Ufone");
        String opChoice = stdin.readLineSync()!;
        String operator;
        switch (opChoice) {
          case '1':
            operator = "Jazz";
            break;
          case '2':
            operator = "Telenor";
            break;
          case '3':
            operator = "Zong";
            break;
          case '4':
            operator = "Ufone";
            break;
          default:
            operator = "Unknown";
        }
        stdout.write("Enter recharge amount: ");
        double rechargeAmount = double.parse(stdin.readLineSync()!);
        system.rechargeMobile(number, operator, rechargeAmount);
        break;

      case '3':
        print("Select Bill Type: 1) Electricity 2) Gas 3) Water");
        String billChoice = stdin.readLineSync()!;
        String billType;
        switch (billChoice) {
          case '1':
            billType = "Electricity";
            break;
          case '2':
            billType = "Gas";
            break;
          case '3':
            billType = "Water";
            break;
          default:
            billType = "Unknown";
        }
        stdout.write("Enter bill amount: ");
        double billAmount = double.parse(stdin.readLineSync()!);
        system.payBill(billType, billAmount);
        break;

      case '4':
        stdout.write("Enter number to save: ");
        String num = stdin.readLineSync()!;
        system.addSavedNumber(num);
        break;

      case '5':
        print("Select Bill Type to Save: 1) Electricity 2) Gas 3) Water");
        String bChoice = stdin.readLineSync()!;
        String bill;
        switch (bChoice) {
          case '1':
            bill = "Electricity";
            break;
          case '2':
            bill = "Gas";
            break;
          case '3':
            bill = "Water";
            break;
          default:
            bill = "Unknown";
        }
        system.addSavedBill(bill);
        break;

      case '6':
        system.viewHistory();
        break;

      case '7':
        print("🚪 Exiting... Goodbye!");
        return;

      default:
        print("❌ Invalid Choice!");
    }
  }
}
