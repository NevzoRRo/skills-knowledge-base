$base = "http://tdgs.gointra.net"
$loginResp = Invoke-WebRequest -Uri "$base/login" -Method POST -Body @{username="<LOGIN>";password="<PASSWORD>"} -SessionVariable session -UseBasicParsing

$ttk = "go-t362-dbs-01.gointra.net"

$xferOps = @(
  @{acc="12345-000"; instrument="LKOH"; place="MICEX_SHR"; qty=100},
  @{acc="12345-000"; instrument="RUR"; place="MICEX_SHR"; qty=50000}
)

foreach ($op in $xferOps) {
  $body = @{
    environment="TTK"; ttk_address=$ttk
    acc_code=$op.acc; instrument=$op.instrument; place_code=$op.place
    quantity=$op.qty; check_limits="false"; confirmed_io="true"
  }
  $r = Invoke-WebRequest -Uri "$base/api/v2/transfer/external" -Method POST -Body $body -WebSession $session -UseBasicParsing
  "Transfer $($op.instrument) x$($op.qty) -> $($op.acc): $($r.Content)"
}
