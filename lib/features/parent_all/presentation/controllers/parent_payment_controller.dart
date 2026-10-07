import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';

class ParentPaymentState {
  final List<InvoiceModel> invoices;
  final String selectedPaymentMethod;
  final bool isProcessing;
  final String? error;

  const ParentPaymentState({
    this.invoices = const [],
    this.selectedPaymentMethod = 'card',
    this.isProcessing = false,
    this.error,
  });

  List<InvoiceModel> get pendingInvoices => invoices.where((i) => !i.isPaid).toList();
  List<InvoiceModel> get paidInvoices => invoices.where((i) => i.isPaid).toList();

  ParentPaymentState copyWith({
    List<InvoiceModel>? invoices,
    String? selectedPaymentMethod,
    bool? isProcessing,
    String? error,
  }) {
    return ParentPaymentState(
      invoices: invoices ?? this.invoices,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
    );
  }
}

final parentPaymentControllerProvider =
    NotifierProvider<ParentPaymentController, ParentPaymentState>(
  ParentPaymentController.new,
);

class ParentPaymentController extends Notifier<ParentPaymentState> {
  late final ParentRepository _repository;

  @override
  ParentPaymentState build() {
    _repository = ref.watch(parentRepositoryProvider);
    Future.microtask(() => loadInvoices());
    return const ParentPaymentState();
  }

  Future<void> loadInvoices() async {
    try {
      final list = await _repository.getInvoices();
      state = state.copyWith(invoices: list);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void selectPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  Future<bool> processPayment(String invoiceId) async {
    state = state.copyWith(isProcessing: true, error: null);
    try {
      await _repository.payInvoice(invoiceId, state.selectedPaymentMethod);
      final updated = await _repository.getInvoices();
      state = state.copyWith(invoices: updated, isProcessing: false);
      return true;
    } catch (e) {
      state = state.copyWith(isProcessing: false, error: e.toString());
      return false;
    }
  }
}
