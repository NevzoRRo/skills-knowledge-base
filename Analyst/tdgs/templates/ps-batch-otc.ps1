$base = "http://tdgs.gointra.net"
$loginResp = Invoke-WebRequest -Uri "$base/login" -Method POST -Body @{username="<LOGIN>";password="<PASSWORD>"} -SessionVariable session -UseBasicParsing

$ttk = "go-t362-dbs-01.gointra.net"
$cpAcc = "COUNTERPARTY-ACC-000"
$date = "2026-07-10"

$otcOps = @(
  @{buyer="12345-000"; instrument="LKOH"; price=5500; qty=10},
  @{buyer="12346-000"; instrument="GAZP"; price=100; qty=10}
)

foreach ($op in $otcOps) {
  $body = @{
    environment="TTK"; ttk_address=$ttk
    seller_acc_code=$cpAcc; buyer_acc_code=$op.buyer
    instrument=$op.instrument; instrument_price=$op.price; quantity=$op.qty
    place_code="MICEX_SHR"; trade_date=$date
    course=1; is_trade_confirmed="true"; is_with_limits="false"; is_trade="true"
  }
  $r = Invoke-WebRequest -Uri "$base/api/v2/save/trade/otc" -Method POST -Body $body -WebSession $session -UseBasicParsing
  "OTC BUY $($op.instrument) x$($op.qty) -> $($op.buyer): $($r.Content)"
}
