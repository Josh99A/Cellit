import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/common/result.dart';
import '../../models/expense_model.dart';
import '../interfaces/expense_datasource.dart';

class ExpenseRemoteDatasourceImpl extends ExpenseDatasource {
  final FirebaseFirestore _firebaseFirestore;

  ExpenseRemoteDatasourceImpl(this._firebaseFirestore);

  @override
  Future<Result<int>> createExpense(ExpenseModel expense) async {
    try {
      await _firebaseFirestore.collection('Expense').doc("${expense.id}").set(expense.toJson());
      // The id has been generated in models
      return Result.success(data: expense.id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateExpense(ExpenseModel expense) async {
    try {
      await _firebaseFirestore
          .collection('Expense')
          .doc("${expense.id}")
          .set(expense.toJson(), SetOptions(merge: true));

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteExpense(int id) async {
    try {
      await _firebaseFirestore.collection('Expense').doc("$id").delete();
      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<ExpenseModel?>> getExpense(int id) async {
    try {
      var res = await _firebaseFirestore.collection('Expense').doc("$id").get();
      if (res.data() == null) return Result.success(data: null);
      return Result.success(data: ExpenseModel.fromJson(res.data()!));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ExpenseModel>>> getAllUserExpenses(String userId) async {
    try {
      var res = await _firebaseFirestore.collection('Expense').where('createdById', isEqualTo: userId).get();
      var expenses = res.docs.map((e) => ExpenseModel.fromJson(e.data())).toList();
      return Result.success(data: expenses);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ExpenseModel>>> getUserExpenses(
    String userId, {
    String orderBy = 'date',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      // Because firestore doesn't support numeric offset
      // Instead, use query cursors. Get last document snapshot then pass it to startAfterDocument
      // https://firebase.google.com/docs/firestore/query-data/query-cursors

      var query = _firebaseFirestore
          .collection('Expense')
          .where('createdById', isEqualTo: userId)
          .orderBy(orderBy, descending: sortBy == 'DESC')
          .limit(limit);

      if (offset != null) {
        DocumentSnapshot<Object?>? lastSnapshot;

        var temp = await _firebaseFirestore
            .collection('Expense')
            .where('createdById', isEqualTo: userId)
            .orderBy(orderBy, descending: sortBy == 'DESC')
            .limit(offset)
            .get();

        lastSnapshot = temp.docs.lastOrNull;

        if (lastSnapshot != null) {
          query = query.startAfterDocument(lastSnapshot);
        } else {
          return Result.success(data: []);
        }
      }

      var rawExpenses = await query.get();
      var expenses = rawExpenses.docs.map((e) => ExpenseModel.fromJson(e.data())).toList();

      return Result.success(data: expenses);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
