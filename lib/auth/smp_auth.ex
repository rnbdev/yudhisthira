defmodule Yudhisthira.Auth.SmpAuth do
  alias Yudhisthira.Utils.Math

  @mod 170141183460469231731687303715884105727 # A big prime maybe?... TODO: Move somewhere else
  @mod_order div(@mod - 1, 2)
  @gen 2

  defp create_random_exponent() do
    # TODO: Improve it with seeds
    # TODO: move seed to config
    Enum.map(
      1..39,
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
    # :crypto.hash(:sha256, message) |>
    #   Base.encode16() |>
    #   Integer.parse(16) |>
    #   Kernel.elem(0)

    :crypto.hash(:sha256, message) |>
      :crypto.bytes_to_integer()
  end

  defp create_log_proof(version, x) do
    rand_exponent = create_random_exponent()
    c = sha256(
      version <> (
        Math.pow(@gen, rand_exponent, @mod) |>
        Integer.to_string() |>
        Base.encode64()
      )
    )
    d = rem(rand_exponent - mulm(x, c, @mod_order), @mod_order)
    {c, d}
  end

  defp check_log_proof(version, g, c, d) do
    gd = Math.pow(@gen, d, @mod)
    gc = Math.pow(g, c, @mod)
    gdgc = gd * gc * @mod
    sha256(
      version <> (gdgc |> Integer.to_string() |> Base.encode64())
    ) == c
  end

  defp create_coords_proof(version, g2, g3, r, secret) do
    r1 = create_random_exponent()
    r2 = create_random_exponent()

    tmp1 = Math.pow(g3, r1, @mod)
    tmp2 = mulm(
      Math.pow(@gen, r1, @mod),
      Math.pow(g2, r2, @mod),
      @mod
    )

    c = sha256(
      version <> (tmp1 |> Integer.to_string()) <> (tmp2 |> Integer.to_string())
    )

    d1 = (r1 - mulm(r, c, @mod_order)) |> rem(@mod_order)
    d2 = (r2 - mulm(secret, c, @mod_order)) |> rem(@mod_order)

    {c, d1, d2}
  end

  defp check_coords_proof(version, c, d1, d2, g2, g3, p, q) do
    tmp1 = mulm(
      Math.pow(g3, d1, @mod),
      Math.pow(p, c, @mod),
      @mod
    )
    
    # Welcome to my life...
    tmp2 = mulm(
      mulm(
        Math.pow(@gen, d1, @mod),
        Math.pow(g2, d2, @mod),
        @mod
      ),
      Math.pow(q, c, @mod),
      @mod
    )

    cprime = sha256(version <> (tmp1 |> Integer.to_string()) <> (tmp2 |> Integer.to_string()))

    c == cprime
  end

  defp create_equal_logs_proof(version, qa, qb, x) do
    r = create_random_exponent()
    tmp1 = Math.pow(@gen, r, @mod)
    qab = mulm(qa, qb, @mod)
    tmp2 = Math.pow(qab, r, @mod)

    c = sha256(
      version <> (tmp1 |> Integer.to_string()) <> (tmp2 |> Integer.to_string())
    )
    tmp1 = mulm(x, c, @mod_order)
    d = rem(r - tmp1, @mod_order)

    {c, d}
  end

  defp check_equal_logs(version, c, d, g3, qab, r) do
    tmp1 = mulm(
      Math.pow(@gen, d, @mod),
      Math.pow(g3, c, @mod),
      @mod
    )

    tmp2 = mulm(
      Math.pow(qab, d, @mod),
      Math.pow(r, c, @mod),
      @mod
    )

    cprime = sha256(
      version <> (tmp1 |> Integer.to_string()) <> (tmp2 |> Integer.to_string())
    )

    c == cprime
  end

  defp valid_argument?(val) do
    (val >= 2) and (val <= @mod - 2)
  end

  defp invm(x) do
    Math.pow(x, @mod - 2, @mod)
  end

  # Step 1
  def create_data_for_auth() do
    IO.puts("Step 1")

    x2 = create_random_exponent()
    x3 = create_random_exponent()

    g2 = Math.pow(@gen, x2, @mod)
    g3 = Math.pow(@gen, x3, @mod)

    {c1, d1} = create_log_proof("1", x2)
    {c2, d2} = create_log_proof("2", x3)

    {
      :ok, 
      %{
        g2: g2,  
        g3: g3,
        c1: c1,
        d1: d1,
        c2: c2,
        d2: d2
      },
      %{
        x2: x2,
        x3: x3,
        g2: g2,
        g3: g3
      }
    }
  end

  # Step 2
  def create_data_for_auth(
    %{
      "c1" => c1,
      "c2" => c2,
      "d1" => d1,
      "d2" => d2,
      "g2" => g2a,
      "g3" => g3a
    },
    %{
      secret: secret
    }
  ) do
    false = (not valid_argument?(g2a)) or (not valid_argument?(g3a))
    false = check_log_proof("1", g2a, c1, d1)
    false = check_log_proof("2", g3a, c2, d2)

    x2 = create_random_exponent()
    x3 = create_random_exponent()

    r = create_random_exponent()

    g2 = Math.pow(@gen, x2, @mod)
    g3 = Math.pow(@gen, x3, @mod)

    {c3, d3} = create_log_proof("3", x2)
    {c4, d4} = create_log_proof("4", x3)

    gb2 = Math.pow(g2a, x2, @mod)
    gb3 = Math.pow(g3a, x3, @mod)

    pb = Math.pow(gb3, r, @mod)
    qb = mulm(
      Math.pow(@gen, r, @mod),
      Math.pow(gb2, secret, @mod),
      @mod
    )

    {c5, d5, d6} = create_coords_proof("5", gb2, gb3, r, secret)

    {
      :ok,
      %{
        g2: g2,
        g3: g3,
        pb: pb,
        qb: qb,
        c3: c3,
        d3: d3,
        c4: c4,
        d4: d4,
        c5: c5,
        d5: d5,
        d6: d6
      },
      %{
        g2a: g2a,
        g3a: g3a,
        x2: x2,
        x3: x3,
        g2: g2,
        g3: g3,
        gb2: gb2,
        gb3: gb3,
        pb: pb,
        qb: qb,
        secret: secret
      }
    }
  end

  # Step 3
  def create_data_for_auth(
    %{
      "g2" => g2b,
      "g3" => g3b,
      "pb" => pb,
      "qb" => qb,
      "c3" => c3,
      "d3" => d3,
      "c4" => c4,
      "d4" => d4,
      "c5" => c5,
      "d5" => d5,
      "d6" => d6
    }, %{
      secret: secret,
      x2: x2,
      x3: x3,
      g2: _,
      g3: _
    }
  ) do
    IO.puts("Step 3")
    false = (not valid_argument?(g2b)) or
      (not valid_argument?(g3b)) or
      (not valid_argument?(pb)) or
      (not valid_argument?(qb))
      
    false = check_log_proof("3", g2b, c3, d3)
    false = check_log_proof("4", g3b, c4, d4)

    ga2 = Math.pow(g2b, x2, @mod)
    ga3 = Math.pow(g3b, x3, @mod)

    false = check_coords_proof("5", c5, d5, d6, ga2, ga3, pb, qb)

    s = create_random_exponent()

    pa = Math.pow(ga3, s, @mod)
    qa = mulm(
      Math.pow(@gen, s, @mod),
      Math.pow(ga2, secret, @mod),
      @mod
    )

    {c6, d7, d8} = create_coords_proof("6", ga2, ga3, s, secret)

    inv = invm(qb)

    ra = Math.pow(
      mulm(qa, inv, @mod),
      x3,
      @mod
    )

    {c7, d9} = create_equal_logs_proof("7", qa, inv, x3)
    
    {
      :ok,
      %{
        pa: pa,
        qa: qa,
        ra: ra,
        c6: c6,
        d7: d7,
        d8: d8,
        c7: c7,
        d9: d9
      },
      %{
        g2b: g2b,
        g3b: g3b,
        ga2: ga2,
        ga3: ga3,
        qb: qb,
        pb: pb,
        pa: pa,
        qa: qa,
        ra: ra
      }
    }
  end

  # Step 4
  def create_data_for_auth(
    %{
      "pa" => pa,
      "qa" => qa,
      "ra" => ra,
      "c6" => c6,
      "d7" => d7,
      "d8" => d8,
      "c7" => c7,
      "d9" => d9
    },
    %{
      g2: _,
      g2a: _,
      g3: _,
      g3a: g3a,
      gb2: gb2,
      gb3: gb3,
      pb: pb,
      qb: qb,
      secret: _,
      x2: _,
      x3: x3
    }
  ) do
    IO.puts("Step 4")
    false = (not valid_argument?(pa)) or
      (not valid_argument?(qa)) or
      (not valid_argument?(ra))

    false = check_coords_proof("6", c6, d7, d8, gb2, gb3, pa, qa)
    false = check_equal_logs("7", c7, d9, g3a, 
      mulm(qa, invm(qb), @mod),
      ra
    )

    inv = invm(qb)
    rb = Math.pow(
      mulm(qa, inv, @mod),
      x3,
      @mod
    )

    {c8, d10} = create_equal_logs_proof("8", qa, inv, x3)

    rab = Math.pow(ra, x3, @mod)

    inv = invm(pb)

    match = rab == mulm(pa, inv, @mod)
    IO.puts("#Matched: #{match}")

    {
      :ok,
      %{
        rb: rb,
        c8: c8,
        d10: d10
      },
      %{
        match: match
      }
    }
  end
end