import 'dart:async';
import 'package:get/get.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../model/wallet_model.dart';

class WalletController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isTransactionsLoading = false.obs;
  RxBool isRechargeLoading = false.obs;

  Rx<WalletModel?> walletModel = Rx<WalletModel?>(null);
  RxList<WalletTransaction> transactions = <WalletTransaction>[].obs;
  RxInt currentPage = 1.obs;
  RxBool hasMorePages = false.obs;

  Timer? _pollingTimer;
  int _pollCount = 0;
  static const int _maxPollRetries = 10;

  @override
  void onInit() {
    super.onInit();
    fetchWallet();
    fetchTransactions();
  }

  @override
  void onClose() {
    _stopPolling();
    super.onClose();
  }

  // ── GET /api/v1/user/wallet ──────────────────────────────────────────────

  Future<void> fetchWallet() async {
    await RequestProcess().request<WalletModel>(
      fromJson: WalletModel.fromJson,
      apiEndpoint: ApiEndpoint.walletBalance,
      isLoading: isLoading,
      onSuccess: (value) {
        walletModel.value = value;
      },
    );
  }

  // ── GET /api/v1/user/wallet/transactions ─────────────────────────────────

  Future<void> fetchTransactions({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      transactions.clear();
    }

    await RequestProcess().request<WalletTransactionsModel>(
      fromJson: WalletTransactionsModel.fromJson,
      apiEndpoint: ApiEndpoint.walletTransactions,
      isLoading: isTransactionsLoading,
      queryParams: {'per_page': '15', 'page': currentPage.value.toString()},
      onSuccess: (value) {
        transactions.addAll(value!.transactions);
        hasMorePages.value = value.pagination.hasMorePages;
        currentPage.value = value.pagination.currentPage + 1;
      },
    );
  }

  void loadMoreTransactions() {
    if (!isTransactionsLoading.value && hasMorePages.value) {
      fetchTransactions();
    }
  }

  // ── POST /api/v1/user/wallet/recharge ────────────────────────────────────

  Future<WalletRechargeModel?> recharge(int amount) async {
    WalletRechargeModel? result;
    await RequestProcess().request<WalletRechargeModel>(
      fromJson: WalletRechargeModel.fromJson,
      apiEndpoint: ApiEndpoint.walletRecharge,
      isLoading: isRechargeLoading,
      method: HttpMethod.POST,
      body: {'amount': amount},
      onSuccess: (value) {
        result = value;
      },
    );
    return result;
  }

  // ── Polling after payment webview returns ─────────────────────────────────

  void startPollingAfterPayment() {
    _pollCount = 0;
    _stopPolling();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      _pollCount++;
      final previousBalance = walletModel.value?.balance ?? 0.0;
      await fetchWallet();
      final newBalance = walletModel.value?.balance ?? 0.0;
      if (newBalance > previousBalance || _pollCount >= _maxPollRetries) {
        _stopPolling();
        if (newBalance > previousBalance) {
          fetchTransactions(refresh: true);
        }
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}
