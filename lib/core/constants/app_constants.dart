abstract final class AppBoxes {
  static const transactions = 'transactions_box';
  static const debts = 'debts_box';
  static const settings = 'settings_box';
  static const subscription = 'subscription_box';
  static const syncQueue = 'sync_queue_box';
  static const wallets = 'wallets_box';
  static const buffers = 'buffers_box';
  static const allocationPlans = 'allocation_plans_box';
  static const reports = 'reports_box';
}

abstract final class AppRoutes {
  static const dashboard = '/';
  static const history = '/history';
  static const debts = '/debts';
  static const settings = '/settings';
  static const addTransaction = '/add-transaction';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const wallets = '/wallets';
  static const buffers = '/buffers';
  static const allocationPlan = '/allocation-plan';
  static const reports = '/reports';
  static const reportView = '/reports/view';
}

