import 'dart:math';

class CalculateFinal {
  /// Calculate rate per payment period
  double ratePerPeriod(double annualRate, int compoundingFreq, int paymentFreq) {
    return pow(1 + annualRate / compoundingFreq, compoundingFreq / paymentFreq) - 1;
  }

  /// 1️⃣ Calculate Payment (PMT)
  double calculatePayment({
    required double principal,
    required double annualRate,
    required int compoundingFreq,
    required int termYears,
    required int paymentFreq,
  }) {
    int totalPayments = termYears * paymentFreq;
    double j = ratePerPeriod(annualRate, compoundingFreq, paymentFreq);
    return principal * j / (1 - pow(1 + j, -totalPayments));
  }

  /// 2️⃣ Calculate Principal (P)
  double calculatePrincipal({
    required double payment,
    required double annualRate,
    required int compoundingFreq,
    required int termYears,
    required int paymentFreq,
  }) {
    int totalPayments = termYears * paymentFreq;
    double j = ratePerPeriod(annualRate, compoundingFreq, paymentFreq);
    return payment * (1 - pow(1 + j, -totalPayments)) / j;
  }

  /// 3️⃣ Calculate Term (n)
  double calculateTermYears({
    required double principal,
    required double payment,
    required double annualRate,
    required int compoundingFreq,
    required int paymentFreq,
  }) {
    double j = ratePerPeriod(annualRate, compoundingFreq, paymentFreq);
    double totalPayments = -log(1 - principal * j / payment) / log(1 + j);
    return totalPayments / paymentFreq;
  }

  /// 4️⃣ Calculate Interest Rate (r) using binary search
  double calculateInterestRate({
    required double principal,
    required double payment,
    required int termYears,
    required int compoundingFreq,
    required int paymentFreq,
    double tolerance = 1e-10,
    int maxIterations = 1000,
  }) {
    double low = 0.0;
    double high = 1.0; // 100% max
    double r = 0.0;

    for (int i = 0; i < maxIterations; i++) {
      r = (low + high) / 2;
      double j = ratePerPeriod(r, compoundingFreq, paymentFreq);
      int N = termYears * paymentFreq;
      double estimatedPayment = principal * j / (1 - pow(1 + j, -N));
      if ((estimatedPayment - payment).abs() < tolerance) break;
      if (estimatedPayment > payment) {
        high = r;
      } else {
        low = r;
      }
    }

    return r;
  }

  /// 5️⃣ Calculate Compounding Frequency (c) using binary search
  double calculateCompoundingFreq({
    required double principal,
    required double payment,
    required double annualRate,
    required int termYears,
    required int paymentFreq,
    double tolerance = 1e-10,
    int maxIterations = 1000,
  }) {
    double low = 1.0; // Annual
    double high = 365.0; // Daily
    double c = 1.0;

    for (int i = 0; i < maxIterations; i++) {
      c = (low + high) / 2;
      double j = pow(1 + annualRate / c, c / paymentFreq) - 1;
      int N = termYears * paymentFreq;
      double estimatedPayment = principal * j / (1 - pow(1 + j, -N));
      if ((estimatedPayment - payment).abs() < tolerance) break;
      if (estimatedPayment > payment) {
        high = c;
      } else {
        low = c;
      }
    }

    return c;
  }

  /// 6️⃣ Calculate Payment Frequency (pf) using binary search
  double calculatePaymentFreq({
    required double principal,
    required double payment,
    required double annualRate,
    required int termYears,
    required int compoundingFreq,
    double tolerance = 1e-10,
    int maxIterations = 1000,
  }) {
    double low = 1.0;
    double high = 365.0;
    double pf = 1.0;

    for (int i = 0; i < maxIterations; i++) {
      pf = (low + high) / 2;
      double j = pow(1 + annualRate / compoundingFreq, compoundingFreq / pf) - 1;
      double N = termYears * pf;
      double estimatedPayment = principal * j / (1 - pow(1 + j, -N));
      if ((estimatedPayment - payment).abs() < tolerance) break;
      if (estimatedPayment > payment) {
        high = pf;
      } else {
        low = pf;
      }
    }

    return pf;
  }

  double remainingPrincipal({
    required double principal,
    required double payment,
    required double annualRate,
    required int compoundingFreq,
    required int paymentFreq,
    required int paymentsMade,
  }) {
    double j = pow(1 + annualRate / compoundingFreq, compoundingFreq / paymentFreq) - 1;
    return principal * pow(1 + j, paymentsMade) - payment * (pow(1 + j, paymentsMade) - 1) / j;
  }
}