import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/koltseg.dart';

class SupabaseKoltsegService {
  final supabase = Supabase.instance.client;

  Future<List<Koltseg>> getKoltsegekForUser(String userId) async {
    try {
      final List<dynamic> data = await supabase
          .from('koltsegek')
          .select()
          .eq('user_id', userId)
          .order('datum', ascending: false);

      return data.map((item) => Koltseg.fromMap(item)).toList();
    } catch (e) {
      //print('Error loading koltsegek: $e');
      return [];
    }
  }

  Future<void> updateMennyiseg(int id, int ujMennyiseg) async {
    await supabase
        .from('koltsegek')
        .update({'mennyiseg': ujMennyiseg})
        .eq('id', id);
  }

  Future<void> updateBalanceByDiff(int diff) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;

    await Supabase.instance.client.rpc(
      'update_balance_diff',
      params: {'p_user_id': userId, 'p_diff': diff},
    );
  }

  Future<List<Koltseg>> getFilteredKoltsegek(
    DateTime from,
    String userId,
  ) async {
    try {
      final List<dynamic> data = await supabase
          .from('koltsegek')
          .select()
          .eq('user_id', userId)
          .gte('datum', from.toIso8601String())
          .order('datum', ascending: false);

      return data.map((item) => Koltseg.fromMap(item)).toList();
    } catch (e) {
      //print('Error loading filtered koltsegek: $e');
      return [];
    }
  }

  Future<void> insertKoltseg(Koltseg koltseg) async {
    try {
      await supabase.from('koltsegek').insert({
        'user_id': koltseg.userId,
        'megnevezes': koltseg.megnevezes,
        'osszeg': koltseg.osszeg,
        'datum': koltseg.datum,
        'mennyiseg': koltseg.mennyiseg,
        'kategoria': koltseg.kategoria,
      });
    } catch (e) {
      //print('Error inserting koltseg: $e');
    }
  }

  Future<void> insertKoltsegWithBalanceUpdate(
    Koltseg koltseg,
    int totalHuf,
  ) async {
    try {
      final client = Supabase.instance.client;

      final balanceRes = await client
          .from('profiles')
          .select('balance')
          .eq('user_id', koltseg.userId)
          .single();

      final int currentBalance = balanceRes['balance'] as int;
      final int newBalance = currentBalance - totalHuf;

      await client.from('koltsegek').insert({
        'user_id': koltseg.userId,
        'megnevezes': koltseg.megnevezes,
        'osszeg': koltseg.osszeg,
        'mennyiseg': koltseg.mennyiseg,
        'datum': koltseg.datum,
        'kategoria': koltseg.kategoria,
      });

      await client
          .from('profiles')
          .update({'balance': newBalance})
          .eq('user_id', koltseg.userId);
    } catch (e) {
      //print('❌ insertKoltsegWithBalanceUpdate error: $e');
      rethrow;
    }
  }

  Future<void> deleteKoltseg(int id) async {
    try {
      await supabase.from('koltsegek').delete().eq('id', id);
    } catch (e) {
      //print('Error deleting koltseg: $e');
    }
  }

  Future<List<Koltseg>> getFilteredKoltsegekRange(
    DateTime from,
    DateTime to,
    String userId,
  ) async {
    final response = await supabase
        .from('koltsegek')
        .select()
        .eq('user_id', userId)
        .gte('datum', from.toIso8601String())
        .lte('datum', to.toIso8601String());

    return (response as List).map((data) => Koltseg.fromMap(data)).toList();
  }

  Future<List<Koltseg>> getMonthlyKoltsegek(
    int year,
    int month,
    String userId,
  ) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(year, month + 1, 0, 23, 59, 59);

    return await getFilteredKoltsegekRange(startOfMonth, endOfMonth, userId);
  }

  Future<List<Koltseg>> getWeeklyKoltsegek(DateTime date, String userId) async {
    final weekday = date.weekday; // 1 = hétfő, 7 = vasárnap
    final startOfWeek = date.subtract(Duration(days: weekday - 1));
    final endOfWeek = startOfWeek.add(
      const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
    );

    return await getFilteredKoltsegekRange(startOfWeek, endOfWeek, userId);
  }

  Future<List<Koltseg>> getDailyKoltsegek(DateTime date, String userId) async {
    final startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return await getFilteredKoltsegekRange(startOfDay, endOfDay, userId);
  }
}
