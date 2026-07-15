$base = "http://tdgs.gointra.net"
$loginResp = Invoke-WebRequest -Uri "$base/login" -Method POST -Body @{username="<LOGIN>";password="<PASSWORD>"} -SessionVariable session -UseBasicParsing

$ttk = "go-t362-dbs-01.gointra.net"
$date = "2026-07-10"

$ops = @(
  @{acc="12345-000"; instrument="LKOH"; price=5500; qty=10; direction="BUY"},
  @{acc="12346-000"; instrument="GAZP"; price=100; qty=10; direction="SELL"}
)

$results = @()
foreach ($op in $ops) {
  $body = @{
    environment="TTK"; ttk_address=$ttk; acc_code=$op.acc
    instrument=$op.instrument; market_type="STOCK_MARKET"
    id_market_board=92; instrument_price=$op.price; instrument_qty=$op.qty
    deal_direction=$op.direction; trade_date_time="$date 14:30:00.000"
    save_to_adfront="false"
  }
  $r = Invoke-WebRequest -Uri "$base/api/v2/save/trade" -Method POST -Body $body -WebSession $session -UseBasicParsing
  $results += "$($op.direction) $($op.instrument) x$($op.qty) on $($op.acc) -> $($r.Content.Substring(0, [Math]::Min(200, $r.Content.Length)))"
}
$results
