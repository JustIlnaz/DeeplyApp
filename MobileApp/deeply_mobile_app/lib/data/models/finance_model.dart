class FinanceRecordModel {
  final int id;
  final String type;
  final String category;
  final double amount;
  final String dateUtc;

  FinanceRecordModel({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.dateUtc,
  });

  factory FinanceRecordModel.fromJson(Map<String, dynamic> j) => FinanceRecordModel(
    id: j['id'],
    type: j['type'] ?? '',
    category: j['category'] ?? '',
    amount: (j['amount'] ?? 0).toDouble(),
    dateUtc: j['dateUtc'] ?? '',
  );
}

class FinanceSummaryModel {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<FinanceRecordModel> recentRecords;
  final List<FinanceGoalModel> goals;

  FinanceSummaryModel({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.recentRecords,
    required this.goals,
  });

  factory FinanceSummaryModel.fromJson(Map<String, dynamic> j) => FinanceSummaryModel(
    totalIncome: (j['totalIncome'] ?? 0).toDouble(),
    totalExpense: (j['totalExpense'] ?? 0).toDouble(),
    balance: (j['balance'] ?? 0).toDouble(),
    recentRecords: (j['recentRecords'] as List? ?? [])
        .map((e) => FinanceRecordModel.fromJson(e))
        .toList(),
    goals: (j['goals'] as List? ?? [])
        .map((e) => FinanceGoalModel.fromJson(e))
        .toList(),
  );
}

class FinanceGoalModel {
  final int id;
  final String title;
  final double targetAmount;
  final double currentAmount;

  FinanceGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
  });

  factory FinanceGoalModel.fromJson(Map<String, dynamic> j) => FinanceGoalModel(
    id: j['id'],
    title: j['title'] ?? '',
    targetAmount: (j['targetAmount'] ?? 0).toDouble(),
    currentAmount: (j['currentAmount'] ?? 0).toDouble(),
  );
}
