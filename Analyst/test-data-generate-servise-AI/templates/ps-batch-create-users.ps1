$base = "http://tdgs.gointra.net"
$loginResp = Invoke-WebRequest -Uri "$base/login" -Method POST -Body @{username="<LOGIN>";password="<PASSWORD>"} -SessionVariable session -UseBasicParsing

$ttk = "go-t362-dbs-01.gointra.net"
$clientsQty = 5
$treatiesPerClient = 3

$body = @{
  environment="TTK"; ttk_address=$ttk
  users_qty=$clientsQty; treaties_qty=$treatiesPerClient
  sos_acctype_id=0; attributes="QUAL"
  adr_index=101000; adr_region="MOSCOW_CITY"
}
$r = Invoke-WebRequest -Uri "$base/api/v2/create/users" -Method POST -Body $body -WebSession $session -UseBasicParsing
$r.Content
