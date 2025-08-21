import 'package:flutter/foundation.dart';
import 'package:imarket/main.dart';

class SubscriptionService {
  Future<bool> hasActiveSubscription() async {
    final user = supabase.auth.currentUser;
    if (user == null) return false;

    final now = DateTime.now().toIso8601String();
    try {
      final response = await supabase
          .from('user_subscriptions')
          .select('subscription_plans(analytics_access)')
          .eq('user_id', user.id)
          .eq('status', 'active')
          .gte('ends_at', now)
          .maybeSingle();

      if (response == null) return false;
      
      final plan = response['subscription_plans'];
      return (plan?['analytics_access'] as bool?) ?? false;

    } catch (e) {
      debugPrint('Error checking for active subscription: $e');
      return false;
    }
  }

  /// Activates a subscription plan for the current user.
  ///
  /// This function finds the plan by its [planIdentifier], deactivates any old
  /// subscriptions by using `upsert`, creates a new active subscription for 30 days, and
  /// updates the user's wallet with the credits from the new plan.
  Future<void> activatePlan(String? planIdentifier) async {
    if (planIdentifier == null || planIdentifier.isEmpty) {
      throw Exception("Plan identifier cannot be null or empty.");
    }

    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("User is not authenticated.");
    }

    try {
      // 1. Find the plan's details from the database.
      final planResponse = await supabase
          .from('subscription_plans')
          .select('id, featured_credits_per_month')
          .eq('code', planIdentifier)
          .single();
          
      final int planId = planResponse['id'];
      final int creditsToAdd = planResponse['featured_credits_per_month'];

      // 2. Prepare subscription data.
      final now = DateTime.now();
      final endDate = now.add(const Duration(days: 30));
      final subscriptionData = {
        'subscription_plan_id': planId,
        'status': 'active',
        'starts_at': now.toIso8601String(),
        'ends_at': endDate.toIso8601String(),
      };

      // 3. Upsert the subscription: Update if one exists for the user, otherwise insert a new one.
      await supabase.from('user_subscriptions').upsert({
        'user_id': user.id,
        ...subscriptionData,
      }, onConflict: 'user_id');

      // 4. Update the user's wallet with the new credits from the plan.
      await supabase
          .from('user_wallet')
          .update({'featured_credits': creditsToAdd}).eq('user_id', user.id);

    } catch (e) {
      debugPrint("Error during plan activation: $e");
      // Rethrow a more user-friendly exception for the UI layer to catch.
      throw Exception("Failed to activate the plan. Please try again.");
    }
  }
}