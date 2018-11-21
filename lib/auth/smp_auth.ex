defmodule Yudhisthira.Auth.SmpAuth do
  alias Yudhisthira.Utils.Math

  @mod 2410312426921032588552076022197566074856950548502459942654116941958108831682612228890093858261341614673227141477904012196503648957050582631942730706805009223062734745341073406696246014589361659774041027169249453200378729434170325843778659198143763193776859869524088940195577346119843545301547043747207749969763750084308926339295559968882457872412993810129130294592999947926365264059284647209730384947211681434464714438488520940127459844288859336526896320919633919
  @mod_order div(@mod - 1, 2)
  @gen 2

  def create_random_exponent() do
    :crypto.strong_rand_bytes(192) |>
      :crypto.bytes_to_integer()

    # 1869088569327812975431022104231139432312601600348843558444995333061295645318228323556173891167413103325494961762954332065944967243350302810468299399508512074910035937858559914061312157938889309309216466365551501586249333409943723147047964212868337367601104829866394117347642808044993763934473863437089677709177633019728297207583171433290859623219762978615903241684956564339557194186374231612721771047454609597355391036836675912964761633591194778541914508963146272
  end

  def mulm(x, y, mod) do
    rem(x * y, mod)
  end

  def sha256(message) do
    :crypto.hash(:sha256, message) |>
      :crypto.bytes_to_integer()
  end

  def create_log_proof(version, x) do
    rand_exponent = create_random_exponent()
    # rand_exponent = 1582688611350845662100034166814149463984698166039584398018251388585340961304393372202489849808518378854917713938463692152972345788948603744395932270974238309474313553175296414461217661455034847912840450626873458095351126320968419904512532457356446096663645785897939179338544913752858955436556484859293880518786515063372422061972049666796570597246755095072637407054689162999920436078323233300037544895513764453040816253798800074659545814353725707664818731535123905
    c = sha256(
      version <> (
        Math.pow(@gen, rand_exponent, @mod) |>
        Integer.to_string()
      )
    )
    d = rem(rand_exponent - mulm(x, c, @mod_order), @mod_order)
    {c, d}
  end

  def check_log_proof(version, g, c, d) do
    gd = Math.pow(@gen, d, @mod)
    gc = Math.pow(g, c, @mod)
    gdgc = rem(gd * gc, @mod)
    sha256(
      version <> (gdgc |> Integer.to_string())
    ) == c
  end

  def create_coords_proof(version, g2, g3, r, secret) do
    # r1 = 886307174552481216258386885660955094153309939301929624164568423809987021536217460136287542800824814472088928749083947615487805992957888655128512076723673861676083295497783924668432010216615262179901539474438927053297169715844333268308421507939959101738439462799009544552405831378070888726113683205984046924665496224731941297008963071405954579547459330625496559863741990970395734334122891116257188567304420469235863816695394877214167635637945008837202018387288767
    r1 = create_random_exponent()
    # r2 = 30796122524494457743186784580024084347755302116037317195902328681565054322818463305041084655909344182667606791400573078246079303164136287397597354332700918695892059017165342356542454564456127123186189248111938418630331328934144834265968761686327996348155914437742848055094284939457245411932048859253688284401910390079539425550710823643671222240535472087021175316187455538611476120828924173482219392331327073842436124115593246549765622356612276936772179102048270
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

  def check_coords_proof(version, c, d1, d2, g2, g3, p, q) do
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
    IO.puts("c")
    IO.inspect(c)
    IO.puts("cprime")
    IO.inspect(cprime)
    c == cprime
  end

  def create_equal_logs_proof(version, qa, qb, x) do
    r = create_random_exponent()
    # r = 2128593305277080552657367396619370261021559250195064005673751813851225102468672082600851683860896078042378391800489019119708415874707862124105440878624850271748119905579754702039737411843940117198776909519576138160436933807430227436502554228486171656870956739404329277586701374499710142124511829729637361742378221752571118848048608378316087196520067753942590576104527334945888719100370725283965131075119072749972228834842664351141150675051404456745572392085926439
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

  def check_equal_logs(version, c, d, g3, qab, r) do
    IO.inspect({
      version,
      c,
      d,
      g3,
      qab,
      r
    })
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

  def valid_argument?(val) do
    (val >= 2) and (val <= @mod - 2)
  end

  def invm(x) do
    Math.pow(x, @mod - 2, @mod)
  end

  # Step 1
  def create_data_for_auth() do
    IO.puts("Step 1")

    x2 = create_random_exponent()
    # x2 = 2124844383341154979610711003795546618809659430153914089487158375237405269541299387954477479779322349953124194267877231780967844312563786056756034810705657302962668270881212915705384079606022641260448857421348562341151678325519744725244346760752409175915995887924386075176343563339389459850319361046203361266948753212495879737661617169632210726570939792478370978880824428914590813411560664411994725626632375274126565131304867715572587127044687569314382244667556712
    x3 = create_random_exponent()
    # x3 = 1400456475993887670142657569119610762877468633926379853355220740214890656182041384184286626073631454760291517177441308102798831718421336226230033321841049478752258669919944427494698074323026843434651132422229896229760709375855219602712798104040927530744740844708297662816156417562097210077999576014389326166111679864555365652775288702508279491741311680320154662633419050821831104731800860980610769396550953271017233009253667641453260411776737787260566949701095906

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
    if (not valid_argument?(g2a)) or (not valid_argument?(g3a)) do
      IO.puts("g2a, g3a failed")
    end

    if not check_log_proof("1", g2a, c1, d1) do
      IO.puts("Proof 1 check failed")
    end
    if not check_log_proof("2", g3a, c2, d2) do
      IO.puts("Proof 2 check failed")
    end
    x2 = create_random_exponent()
    # x2 = 306213481295777610618075123510719385451881167840929486634893505990738489264855788134587524865396955759872716568913288338456964812431404899131828004795837030714734527565614594532784817071593200505726430602859525809466294859056390476204818729048864052793234129595387132727508704038706675828172506483907987350497271251452800268644495519516976054800555607353713829708579499976435582335294289663835737050188990950394511731507054382905529918559844393221028892948324108
    x3 = create_random_exponent()
    # x3 = 1629733757963029049994403828887041205599295833532604317976739336762276602480800580478459230765262169625717534378723668979476504393996130723901033812816233555712128324042809537713809897478549039586888671568570148612944245279565989206330185086727695425416619734694619851603534356456814569198395511306197939247564248360484127561304641279267890605475762119073271395497199561664914586563027338418083466264583283262644268429276710725782771480837009327256366552418778160

    r = create_random_exponent()
    # r = 2114832063971390287622237419537198986147799561144628660205876324201518667433713342900668840001398757319569505589171377259587834860361765052840627831306646629833413500111600421987741017835581192826994667877804810504099970291643135404658329673922866908894128597029076191837085901188838556983271575619236589469103325269571772273914430117323730435649632550176718765051525948343037699823030235049726447220894079755314229861887042674059797457919911843470416846852507197

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
    } , %{
      secret: secret,
      x2: x2,
      x3: x3,
      g2: _,
      g3: _
    }
  ) do
    IO.puts("Step 3")
    IO.puts("before check")
    if (not valid_argument?(g2b)) or
      (not valid_argument?(g3b)) or
      (not valid_argument?(pb)) or
      (not valid_argument?(qb)) do
        IO.puts("args failed")
    end

    IO.inspect(%{
      g2b: g2b,
      c3: c3,
      d3: d3
    })
    if not check_log_proof("3", g2b, c3, d3) do
      IO.puts("log proof 3 check failed")
    end

    IO.inspect({"secret", secret})
    if not check_log_proof("4", g3b, c4, d4) do
      IO.puts("log proof 4 check faile")
    end

    ga2 = Math.pow(g2b, x2, @mod)

    IO.inspect({
      "ga2",
      ga2
    })
    ga3 = Math.pow(g3b, x3, @mod)

    # IO.puts("Before coords proof")
    # IO.inspect(%{
    #   "ga2" => ga2,
    #   "ga3" => ga3,
    #   "pb" => pb,
    #   "qb" => qb,
    #   "c3" => c3,
    #   "d3" => d3,
    #   "c4" => c4,
    #   "d4" => d4,
    #   "c5" => c5,
    #   "d5" => d5,
    #   "d6" => d6,
    #   "secret" => secret,
    #   "x2" => x2,
    #   "x3" => x3
    # })

    if not check_coords_proof("5", c5, d5, d6, ga2, ga3, pb, qb) do
      IO.puts("Proof 5 check failed")
    end
    s = create_random_exponent()
    IO.puts("after coords proof")
    # s = 1371589671996467676465597434778912370801966549633360954442645745558305564269464588464486420109987131528432505463679948374929937812013448974506727589439481163300415895111814442398860375820305015761377874283784865374381746071681207602895336191278525784628903002250385789398996731155128997626403963958733031491101605530646636432691561861198320669212078474554224833395159764470743961806746437330543355790255572755086133511269778638418964440495231793785286037712298524

    pa = Math.pow(ga3, s, @mod)
    qa = mulm(
      Math.pow(@gen, s, @mod),
      Math.pow(ga2, secret, @mod),
      @mod
    )

    {c6, d7, d8} = create_coords_proof("6", ga2, ga3, s, secret)
    inv = invm(qb)

    IO.puts("qa")
    IO.inspect(qa)

    IO.puts("inv")
    IO.inspect(inv)

    ra = Math.pow(
      mulm(qa, inv, @mod),
      x3,
      @mod
    )

    IO.puts("ra")
    IO.inspect(ra)

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
    if (not valid_argument?(pa)) or
      (not valid_argument?(qa)) or
      (not valid_argument?(ra)) do
      IO.puts("Args failed")
    end

    if not check_coords_proof("6", c6, d7, d8, gb2, gb3, pa, qa) do
      IO.puts("Proof 6 failed")
    end

    if not check_equal_logs("7", c7, d9, g3a, 
      mulm(qa, invm(qb), @mod),
      ra
    ) do
      IO.puts("Proof 7 failed")
    end

    inv = invm(qb)
    rb = Math.pow(
      mulm(qa, inv, @mod),
      x3,
      @mod
    )

    {c8, d10} = create_equal_logs_proof("8", qa, inv, x3)

    rab = Math.pow(ra, x3, @mod)

    IO.puts("ra")    
    IO.inspect(ra)
    IO.puts("rab")    
    IO.inspect(rab)
    IO.puts("x3")    
    IO.inspect(x3)
    IO.puts("rab")    
    IO.inspect(rab)

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

  def check_auth_data_final(rb, c8, d10, x3, pa, pb, g3b, qa, qb) do
    IO.puts("Step 5")
    if not valid_argument?(rb) do
      IO.puts("Invalid rb value")
    end
      
    if not check_equal_logs("8", c8, d10, g3b,
      mulm(qa, invm(qb), @mod),
      rb
    ) do
      IO.puts("Proof 8 failed")
    end

    rab = Math.pow(rb, x3, @mod)

    inv = invm(pb)

    match = rab == mulm(pa, inv, @mod)
    IO.puts("#Matched: #{match}")
  end
end