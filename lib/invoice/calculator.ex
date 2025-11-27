defmodule Invoice.Calculator do
  def compute(params) do
    %{
      "gold_value" => gold,
      "stone_value" => stone,
      "misc_value" => msc,
      "making_charge" => mc,
      "hallmark_charge" => hm,
      "cgst_value" => cgst,
      "sgst_value" => sgst,
      "customer_asked_value" => fnew
    } = params

    # Normalize all inputs to floats once
    gold = to_float(gold)
    stone = to_float(stone)
    msc = to_float(msc)
    mc = to_float(mc)
    hm = to_float(hm)
    fnew = to_float(fnew)
    sgst = to_float(sgst)
    cgst = to_float(cgst)

    # pre gst value
    pre_subtotal =
      gold
      |> then(&(&1 + stone))
      |> then(&(&1 + msc))
      |> then(&(&1 + mc))
      |> then(&(&1 + hm))

    gst_rate =
      cgst
      |>then(&(&1 + sgst))
      |>then(&(&1 / 100.00))

    # post gst value
    post_subtotal =
      pre_subtotal
      |> then(&(&1 * (1.00 + gst_rate)))

    # new post gst substoal after customer asked discount
    new_post_subtotal =
        post_subtotal
        |> then(&(&1 - fnew))

    # adjusted discount price
    required_pre_gst =
      new_post_subtotal
      |> then(&(&1 / (1.0 + gst_rate)))

    # difference bettwen the pre_gst and required_pregst
    difference =
      pre_subtotal
      |> then(&(&1 - required_pre_gst))

    #new making charge
    new_mc =
      mc
      |>then(&(&1 - difference))
      |> then(&max(&1, 0.0))

    # discount percent on making charge
    discount_on_mc =
      mc
      |> then(fn safe_mc ->
        cond do
           safe_mc == 0.0 ->
            0.0

            true ->
              safe_mc
              |> then(&(&1 - new_mc))
              |> then(&(&1 / safe_mc))
              |> then(&(&1 * 100.00))


        end
      end)


    # now pre gst subtotal value after adjusting making charges
    m_pre_subtotal_value =
      gold
      |> then(&(&1 + stone))
      |> then(&(&1 + msc))
      |> then(&(&1 + new_mc))
      |> then(&(&1 + hm))

    # now post gst susbtotal value after adjusting making charges
    m_post_subtotal_value =
      m_pre_subtotal_value
      |> then(&(&1 * (1.00 + gst_rate)))

    %{
      pre_subtotal: format(pre_subtotal),
      post_subtotal: format(post_subtotal),
      fnew: format(fnew),
      required_pre_gst: format(required_pre_gst),
      new_mc: format(new_mc),
      m_post_subtotal_value: format(m_post_subtotal_value),
      new_post_subtotal: format(new_post_subtotal),
      discount_on_mc: format(discount_on_mc)
    }





  end

  def to_float(nil), do: 0.0
  def to_float(""), do: 0.0

  def to_float(value) when is_binary(value) do
    case Float.parse(value) do
      {num, _} -> num
      :error -> 0.0
    end
  end

  def to_float(value) when is_number(value), do: value * 1.0

  defp format(num) do
    num
    |> to_float()
    |> Float.round(2)
    |> :erlang.float_to_binary(decimals: 2)
  end
end
