import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@12.12.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// تهيئة Stripe باستخدام المفتاح السري
const stripe = Stripe(Deno.env.get("STRIPE_SECRET_KEY"), {
  apiVersion: "2022-11-15",
  httpClient: Stripe.createFetchHttpClient(),
});

serve(async (req) => {
  const signature = req.headers.get("Stripe-Signature");
  const body = await req.text();

  try {
    // التحقق من أن الطلب قادم بالفعل من Stripe
    const event = await stripe.webhooks.constructEventAsync(
      body,
      signature!,
      Deno.env.get("STRIPE_WEBHOOK_SIGNING_SECRET")!,
    );

    // التعامل فقط مع حدث "checkout.session.completed"
    if (event.type === "checkout.session.completed") {
      const session = event.data.object;
      const userId = session.client_reference_id;
      const amount = session.amount_total / 1000; // تحويل من فلس إلى دينار

      // استدعاء دالة قاعدة البيانات لإضافة النقاط للمستخدم
      const supabaseAdmin = createClient(
        Deno.env.get("SUPABASE_URL") ?? "",
        Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "",
      );

      // تحديد عدد النقاط بناءً على المبلغ المدفوع
      let creditsToAdd = 0;
      if (amount === 3) {
        creditsToAdd = 5;
      } else if (amount === 5) {
        creditsToAdd = 10;
      } else if (amount === 10) {
        // هذا للاشتراك، يمكنك إضافة منطق مختلف هنا لاحقًا
      }

      if (creditsToAdd > 0 && userId) {
        const { error } = await supabaseAdmin.rpc("purchase_feature_credits", {
          p_user_id: userId, // إرسال هوية المستخدم للدالة
          p_credits_to_add: creditsToAdd,
        });

        if (error) {
          console.error("Supabase RPC error:", error);
          throw error;
        }
      }
    }

    return new Response(JSON.stringify({ received: true }), { status: 200 });
  } catch (err) {
    console.error("Webhook error:", err.message);
    return new Response(`Webhook Error: ${err.message}`, { status: 400 });
  }
});