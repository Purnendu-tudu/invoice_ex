defmodule InvoiceWeb.InvoiceLive do
  use InvoiceWeb, :live_view

  alias Invoice.Calculator

  def mount(_params, _session, socket) do
    form =
      to_form(%{
        "gold_value" => "",
        "stone_value" => "",
        "misc_value" => "",
        "making_charge" => "",
        "hallmark_charge" => "",
        "cgst_value" => "",
        "sgst_value" => "",
        "customer_asked_value" => ""
      })

    IO.inspect(socket)

    socket =
      socket
      |> assign(:form, form)
      |> assign(:result, nil)

    {:ok, socket}
  end

  def render(assigns) do
    # ~H"""
    #   <div class="invoice">
    #     <h1>Invoice Calculator</h1>
    #     <.form for={@form} phx-change="recalc" phx-submit="recalc">
    #       <.input  class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" type="number" field={@form[:gold_value]} step="0.01" label="Gold Price"  />
    #       <.input type="number" field={@form[:stone_value]} step="0.01" label="Stone Value"/>
    #       <.input type="number" field={@form[:misc_value]} step="0.01" label="Misc Value" />
    #       <.input type="number" field={@form[:making_charge]} step="0.01" label="Making Charge" />
    #       <.input type="number" field={@form[:hallmark_charge]} step="0.01" label="HallMark Charge" />
    #       <.input type="number" field={@form[:cgst_value]} step="0.01" label="CGST Value" />
    #       <.input type="number" field={@form[:sgst_value]} step="0.01" label="SGST Value" />
    #       <.input type="number" field={@form[:customer_asked_value]} step="0.01" label="Customer Asked Value"/>

    #     </.form>

    #     <h2>Live Invoice Calculation</h2>
    #     <%= if @result do %>
    #       <div class="result">
    #         <p> Original Subtotal : ₹ <%= @result.pre_subtotal %> </p>
    #         <p> After Gst Price : ₹ <%= @result.post_subtotal %> </p>
    #         <p> Customer asked Discount Needed : ₹ <%= @result.fnew %> </p>
    #         <p> New Price After the Customer Discounted (post GST): ₹ <%= @result.new_post_subtotal %> </p>
    #         <p> Adjust Price : ₹ <%= @result.required_pre_gst %> </p>
    #         <p> New Making Charge : ₹ <%= @result.new_mc %> </p>
    #         <p> New Making Charge Discount : <%= @result.discount_on_mc %>% </p>

    #         <p> New Final Gross : ₹ <%= @result.m_post_subtotal_value %> </p>

    #       </div>
    #     <% end %>

    #   </div>
    # """

    ~H"""
    <div class="invoice max-w-md mx-auto p-4 space-y-6 bg-white">
      <h1 class="text-xl font-bold text-center tracking-wide">Invoice Calculator</h1>

      <.form for={@form} phx-change="recalc" phx-submit="recalc" class="space-y-4">
        
    <!-- Input fields -->
        <div class="space-y-3">
          <.input
            class="w-full px-3 py-2 border border-gray-400 focus:border-black focus:ring-0 rounded-none text-base"
            type="number"
            field={@form[:gold_value]}
            step="0.01"
            label="Gold Price"
          />

          <.input
            class="w-full px-3 py-2 border border-gray-400 focus:border-black focus:ring-0 rounded-none text-base"
            type="number"
            field={@form[:stone_value]}
            step="0.01"
            label="Stone Value"
          />

          <.input
            class="w-full px-3 py-2 border border-gray-400 focus:border-black focus:ring-0 rounded-none text-base"
            type="number"
            field={@form[:misc_value]}
            step="0.01"
            label="Misc Value"
          />

          <.input
            class="w-full px-3 py-2 border border-gray-400 focus:border-black focus:ring-0 rounded-none text-base"
            type="number"
            field={@form[:making_charge]}
            step="0.01"
            label="Making Charge"
          />

          <.input
            class="w-full px-3 py-2 border border-gray-400 focus:border-black focus:ring-0 rounded-none text-base"
            type="number"
            field={@form[:hallmark_charge]}
            step="0.01"
            label="Hallmark Charge"
          />

          <.input
            class="w-full px-3 py-2 border border-gray-400 focus:border-black focus:ring-0 rounded-none text-base"
            type="number"
            field={@form[:cgst_value]}
            step="0.01"
            label="CGST (%)"
          />

          <.input
            class="w-full px-3 py-2 border border-gray-400 focus:border-black focus:ring-0 rounded-none text-base"
            type="number"
            field={@form[:sgst_value]}
            step="0.01"
            label="SGST (%)"
          />

          <.input
            class="w-full px-3 py-2 border border-gray-400 focus:border-black focus:ring-0 rounded-none text-base"
            type="number"
            field={@form[:customer_asked_value]}
            step="0.01"
            label="Customer Asked Discount"
          />
        </div>
      </.form>

      <h2 class="text-lg font-semibold border-b pb-2">Live Invoice Calculation</h2>

      <%= if @result do %>
        <div class="result text-base space-y-2">
          <div class="flex justify-between">
            <span>Original Subtotal:</span>
            <span class="font-semibold">₹ {@result.pre_subtotal}</span>
          </div>

          <div class="flex justify-between">
            <span>After GST Price:</span>
            <span class="font-semibold">₹ {@result.post_subtotal}</span>
          </div>

          <div class="flex justify-between">
            <span>Customer Discount Needed:</span>
            <span class="font-semibold">₹ {@result.fnew}</span>
          </div>

          <div class="flex justify-between">
            <span>New Price After Discount (post-GST):</span>
            <span class="font-semibold">₹ {@result.new_post_subtotal}</span>
          </div>

          <div class="flex justify-between">
            <span>Required Pre-GST Adjust Price:</span>
            <span class="font-semibold">₹ {@result.required_pre_gst}</span>
          </div>

          <div class="flex justify-between">
            <span>New Making Charge:</span>
            <span class="font-semibold">₹ {@result.new_mc}</span>
          </div>

          <div class="flex justify-between">
            <span>Making Charge Discount %:</span>
            <span class="font-semibold">{@result.discount_on_mc}%</span>
          </div>

          <div class="flex justify-between border-t pt-2 text-lg font-bold">
            <span>New Final Gross:</span>
            <span>₹ {@result.m_post_subtotal_value}</span>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("recalc", params, socket) do
    result = Calculator.compute(params)

    socket =
      socket
      |> assign(:form, to_form(params))
      |> assign(:result, result)

    {:noreply, socket}
  end
end
