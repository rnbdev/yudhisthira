defmodule Yudhisthira.Auth.SmpAuth do
  alias Yudhisthira.Utils.Config
  alias Yudhisthira.Utils.Math

  @mod 245464264623526464 # A big prime maybe?... TODO: Move somewhere else
  @mod_order div(@mod - 1, 2)
  @gen 2

  defp create_random_exponent() do
    # TODO: Make sure this has a fixed length o/p
    # Can't move without it
    # TODO: Improve it with seeds
    # TODO: move to config
    Enum.map(
      1..32,
      fn _ -> Integer.to_string(:rand.uniform(9)) end
    ) |>
    Enum.join("") |>
    Integer.parse(10) |>
    Kernel.elem(0)
  end

  defp mulm(x, y, mod) do
    rem(x * y, mod)
  end

  defp sha256(message) do
    :crypto.hash(:sha256, message) |>
      Base.encode16() |>
      Integer.parse(16) |>
      Kernel.elem(0)
  end

  defp create_log_proof(version, x) do
    rand_exponent = create_random_exponent()
    c = sha256(
      version <> (
        Math.pow(@gen, rand_exponent, @mod) |> Base.encode64()
      ) 
    )
    d = rem(rand_exponent - mulm(x, c, @mod_order), @mod_order)
    {c, d}
  end

  defp check_log_proof(version, g, c, d) do
    
  end

  defp create_coords_proof(version, g2, g3, r) do

  end

  defp check_coords_proof(version, c, d1, d2, g2, g3, p, q) do

  end

  defp equal_logs(version, c, d, g3, qab, r) do
    
  end

  defp valid_argument?(val) do
    (val >= 2) and (val <= @mod - 2)
  end

  defp invm(x) do
    Math.pow(x, @mod - 2, @mod)
  end

  def create_data_for_step_1() do
    x2 = create_random_exponent()
    x3 = create_random_exponent()

    IO.inspect(x2)
    IO.inspect(x3)
    g2 = Math.pow(@gen, x2, @mod) |> Base.encode64()
    g3 = Math.pow(@gen, x3, @mod) |> Base.encode64()

    {c1, d1} = create_log_proof("1", x2)
    {c2, d2} = create_log_proof("2", x3)

    %{
      g2: g2,  
      g3: g3,
      c1: c1,
      d1: d1,
      c2: c2,
      d2: d2
    }
  end
end