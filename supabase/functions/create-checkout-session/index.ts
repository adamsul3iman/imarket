// supabase/functions/create-checkout-session/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.4.0';

serve(async (req) => {
  if (req.method !== 'POST') {
    return new Response('Method Not Allowed', { status: 405 });
  }

  const { amount, currency, description, email, name, userId } = await req.json();

  // احصل على مفتاح Tap API السري من متغيرات البيئة
  const TAP_SECRET_KEY = Deno.env.get('TAP_SECRET_KEY');
  if (!TAP_SECRET_KEY) {
    return new Response('Tap API key not found.', { status: 500 });
  }

  // بيانات الشحنة (Charge) لـ Tap
  const chargeData = {
    amount: amount,
    currency: currency,
    description: description,
    statement_descriptor: 'iMarket JO Subscription',
    metadata: { userId: userId },
    customer: {
      first_name: name,
      email: email,
    },
    source: { id: 'src_all' },
    redirect: {
      url: `${Deno.env.get('SUPABASE_URL')}/success`,
    },
  };

  try {
    // استدعاء Tap API لإنشاء جلسة الدفع
    const tapResponse = await fetch('https://api.tap.company/v2/charges', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${TAP_SECRET_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(chargeData),
    });

    const tapResult = await tapResponse.json();

    // تحقق من نجاح العملية وإرجاع رابط الدفع
    if (tapResult && tapResult.transaction && tapResult.transaction.url) {
      return new Response(JSON.stringify({ url: tapResult.transaction.url }), {
        headers: { 'Content-Type': 'application/json' },
      });
    } else {
      debugPrint('Tap API Error:', tapResult.errors);
      return new Response(JSON.stringify({ error: tapResult.errors }), {
        status: 400,
        headers: { 'Content-Type': 'application/json' },
      });
    }
  } catch (e) {
    debugPrint("Error creating Tap charge: ", e);
    return new Response('Failed to create Tap checkout session.', { status: 500 });
  }
});