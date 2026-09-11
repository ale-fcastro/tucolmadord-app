class DaySummary {
  final double totalSales;
  final int salesCount;
  final double cashTotal;
  final double transferTotal;
  final double fiadoTotal;
  final double expensesTotal;
  final double estimatedProfit;
  final bool closed;

  const DaySummary({
    required this.totalSales,
    required this.salesCount,
    required this.cashTotal,
    required this.transferTotal,
    required this.fiadoTotal,
    required this.expensesTotal,
    required this.estimatedProfit,
    required this.closed,
  });

  static const empty = DaySummary(
    totalSales: 0,
    salesCount: 0,
    cashTotal: 0,
    transferTotal: 0,
    fiadoTotal: 0,
    expensesTotal: 0,
    estimatedProfit: 0,
    closed: false,
  );
}
