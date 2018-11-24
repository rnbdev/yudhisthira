defmodule Yudhisthira.Auth.SmpAuth do
  import Yudhisthira.Utils.Math
  import Yudhisthira.Utils.Config, only: [config: 1]
  require Logger

  @mod config(:smp_mod)
  @mod_order div(@mod - 1, 2)
  @gen 2

  def create_log_proof(version, x) do
    rand_exponent = create_random_exponent()
    c = sha256(
      version <> (
        pow(@gen, rand_exponent, @mod) |>
        Integer.to_string()
      )
    )
    d = rem(rand_exponent - mulm(x, c, @mod_order), @mod_order)
    {c, d}
  end

  def check_log_proof(version, g, c, d) do
    gd = pow(@gen, d, @mod)
    gc = pow(g, c, @mod)
    gdgc = rem(gd * gc, @mod)
    sha256(
      version <> (gdgc |> Integer.to_string())
    ) == c
  end

  def create_coords_proof(version, g2, g3, r, secret) do
    r1 = create_random_exponent()
    r2 = create_random_exponent()

    tmp1 = pow(g3, r1, @mod)
    tmp2 = mulm(
      pow(@gen, r1, @mod),
      pow(g2, r2, @mod),
      @mod
    )

    c = sha256(
      version <> (tmp1 |> Integer.to_string()) <> (tmp2 |> Integer.to_string())
    )

    d1 = (r1 - mulm(r, c, @mod_order)) |> rem(@mod_order)
    d2 = (r2 - mulm(secret, c, @mod_order)) |> rem(@mod_order)

    {c, d1, d2}
  end

  def check_coords_proof(version, c, d1, d2, g2, g3, p, q) do
    tmp1 = mulm(
      pow(g3, d1, @mod),
      pow(p, c, @mod),
      @mod
    )
    
    tmp2 = mulm(
      mulm(
        pow(@gen, d1, @mod),
        pow(g2, d2, @mod),
        @mod
      ),
      pow(q, c, @mod),
      @mod
    )

    cprime = sha256(version <> (tmp1 |> Integer.to_string()) <> (tmp2 |> Integer.to_string()))
    c == cprime
  end

  def create_equal_logs_proof(version, qa, qb, x) do
    r = create_random_exponent()
    tmp1 = pow(@gen, r, @mod)
    qab = mulm(qa, qb, @mod)
    tmp2 = pow(qab, r, @mod)

    c = sha256(
      version <> (tmp1 |> Integer.to_string()) <> (tmp2 |> Integer.to_string())
    )
    tmp1 = mulm(x, c, @mod_order)
    d = rem(r - tmp1, @mod_order)

    {c, d}
  end

  def check_equal_logs(version, c, d, g3, qab, r) do
    tmp1 = mulm(
      pow(@gen, d, @mod),
      pow(g3, c, @mod),
      @mod
    )

    tmp2 = mulm(
      pow(qab, d, @mod),
      pow(r, c, @mod),
      @mod
    )

    cprime = sha256(
      version <> (tmp1 |> Integer.to_string()) <> (tmp2 |> Integer.to_string())
    )

    c == cprime
  end

  def valid_argument?(val) do
    (val >= 2) and (val <= @mod - 2)
  end

  def invm(x) do
    pow(x, @mod - 2, @mod)
  end

  # Step 1
  def create_data_for_auth() do
    x2 = create_random_exponent()
    x3 = create_random_exponent()

    g2 = pow(@gen, x2, @mod)
    g3 = pow(@gen, x3, @mod)

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
    if (not valid_argument?(g2a)) or (not valid_argument?(g3a)) do
      Logger.info("g2a, g3a args failed")
    end

    if not check_log_proof("1", g2a, c1, d1) do
      Logger.info("Proof 1 check failed")
    end
    if not check_log_proof("2", g3a, c2, d2) do
      Logger.info("Proof 2 check failed")
    end

    x2 = create_random_exponent()
    x3 = create_random_exponent()

    r = create_random_exponent()

    g2 = pow(@gen, x2, @mod)
    g3 = pow(@gen, x3, @mod)

    {c3, d3} = create_log_proof("3", x2)
    {c4, d4} = create_log_proof("4", x3)

    gb2 = pow(g2a, x2, @mod)
    gb3 = pow(g3a, x3, @mod)

    pb = pow(gb3, r, @mod)
    qb = mulm(
      pow(@gen, r, @mod),
      pow(gb2, secret, @mod),
      @mod
    )

    {c5, d5, d6} = create_coords_proof("5", gb2, gb3, r, secret)

    {
      :ok,
      %{
        "g2" => g2,
        "g3" => g3,
        "pb" => pb,
        "qb" => qb,
        "c3" => c3,
        "d3" => d3,
        "c4" => c4,
        "d4" => d4,
        "c5" => c5,
        "d5" => d5,
        "d6" => d6
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
    } , %{
      secret: secret,
      x2: x2,
      x3: x3,
    }
  ) do
    if (not valid_argument?(g2b)) or
      (not valid_argument?(g3b)) or
      (not valid_argument?(pb)) or
      (not valid_argument?(qb)) do
        Logger.info("step 3 args failed")
    end

    if not check_log_proof("3", g2b, c3, d3) do
      Logger.info("log proof 3 check failed")
    end

    if not check_log_proof("4", g3b, c4, d4) do
      Logger.info("log proof 4 check failed")
    end

    ga2 = pow(g2b, x2, @mod)

    ga3 = pow(g3b, x3, @mod)

    if not check_coords_proof("5", c5, d5, d6, ga2, ga3, pb, qb) do
      IO.puts("Proof 5 check failed")
    end
    s = create_random_exponent()

    pa = pow(ga3, s, @mod)
    qa = mulm(
      pow(@gen, s, @mod),
      pow(ga2, secret, @mod),
      @mod
    )

    {c6, d7, d8} = create_coords_proof("6", ga2, ga3, s, secret)
    inv = invm(qb)

    ra = pow(
      mulm(qa, inv, @mod),
      x3,
      @mod
    )

    {c7, d9} = create_equal_logs_proof("7", qa, inv, x3)
    
    {
      :ok,
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
      g3a: g3a,
      gb2: gb2,
      gb3: gb3,
      pb: pb,
      qb: qb,
      x3: x3
    }
  ) do
    if (not valid_argument?(pa)) or
      (not valid_argument?(qa)) or
      (not valid_argument?(ra)) do
      Logger.info("Args failed")
    end

    if not check_coords_proof("6", c6, d7, d8, gb2, gb3, pa, qa) do
      Logger.info("Proof 6 failed")
    end

    if not check_equal_logs("7", c7, d9, g3a, 
      mulm(qa, invm(qb), @mod),
      ra
    ) do
      Logger.info("Proof 7 failed")
    end

    inv = invm(qb)
    rb = pow(
      mulm(qa, inv, @mod),
      x3,
      @mod
    )

    {c8, d10} = create_equal_logs_proof("8", qa, inv, x3)

    rab = pow(ra, x3, @mod)

    inv = invm(pb)

    match = rab == mulm(pa, inv, @mod)

    {
      :ok,
      %{
        "rb" => rb,
        "c8" => c8,
        "d10" => d10
      },
      %{match: match}
    }
  end

  def check_auth_data_final(rb, c8, d10, x3, pa, pb, g3b, qa, qb) do
    if not valid_argument?(rb) do
      Logger.info("Invalid rb value")
    end
      
    if not check_equal_logs("8", c8, d10, g3b,
      mulm(qa, invm(qb), @mod),
      rb
    ) do
      Logger.info("Proof 8 failed")
    end

    rab = pow(rb, x3, @mod)

    inv = invm(pb)

    case rab == mulm(pa, inv, @mod) do
      true -> {:ok, :match}
      false -> {:error, :nomatch}
    end
    
  end
end