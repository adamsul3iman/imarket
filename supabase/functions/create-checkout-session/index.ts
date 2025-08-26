import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import Stripe from "https://esm.sh/stripe@12.12.0?target=deno";

// ✅ FIX: Define CORS headers to allow requests from any origin (*).
// For production, you might want to restrict this to your actual website URL.
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const stripe = Stripe(Deno.env.get("STRIPE_SECRET_KEY"), {
  apiVersion: "2022-11-15",
  httpClient: Stripe.createFetchHttpClient(),
});

serve(async (req) => {
  // This is needed for the browser's preflight request.
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const { amount, description, userId } = await req.json();

    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      line_items: [
        {
          price_data: {
            currency: "jod",
            product_data: {
              name: description || "iMarket JO Purchase",
            },
            unit_amount: Math.round(amount * 1000),
          },
          quantity: 1,
        },
      ],
      mode: "payment",
      success_url: `http://localhost:3000/payment/success`, // Use a placeholder for now
      cancel_url: `http://localhost:3000/payment/cancel`,
      client_reference_id: userId, 
    });

    return new Response(JSON.stringify({ url: session.url }), {
      // ✅ FIX: Add CORS headers to the success response.
      headers: { ...corsHeaders, "Content-Type": "application/json" }, 
    });

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      // ✅ FIX: Add CORS headers to the error response.
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});