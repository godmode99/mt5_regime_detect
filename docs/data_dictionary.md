# Data Dictionary

The table below defines every field exported from the `RegimeFeature` struct. All values are automatically derived from indicator logic.

| Field Name | Data Type | Description | Possible Values/Enum | Expected Range/Threshold | Example Value | Logic/Formula |
| --- | --- | --- | --- | --- | --- | --- |
| time | datetime | Bar time stamp | unix seconds | n/a | `1623495600` | `rates[0].time` value |
| symbol | string | Trading symbol | e.g. `EURUSD` | n/a | `EURUSD` | `_Symbol` from MT5 |
| open | double | Open price | n/a | n/a | `1.1000` | `rates[0].open` |
| high | double | High price | n/a | n/a | `1.1050` | `rates[0].high` |
| low | double | Low price | n/a | n/a | `1.0980` | `rates[0].low` |
| close | double | Close price | n/a | n/a | `1.1020` | `rates[0].close` |
| tick_volume | long | Tick volume | n/a | n/a | `150` | `rates[0].tick_volume` |
| bos | bool | Break of Structure flag | `0` = false, `1` = true | n/a | `1` | `DetectBOS` compares current high/low with recent swings and returns true if either is broken. |
| trend_dir | enum | Trend direction | `0`=TREND_NONE, `1`=TREND_UP, `2`=TREND_DOWN | n/a | `1` | `GetTrendDirection` checks the close price change over a lookback window. |
| range_compression | bool | Sideway range compression detection | `0` = false, `1` = true | current range < 50% of lookback range | `0` | `DetectRangeCompression` compares current bar range to the max/min range over the window. |
| volume_spike | bool | Volume spike confirmation | `0` = false, `1` = true | volume > 1.5×20‑bar average | `1` | `DetectVolumeSpike` flags if volume exceeds the moving average by a multiplier. |
| divergent | bool | Volume divergence | `0` = false, `1` = true | n/a | `0` | `DetectVolumeDivergence` looks for opposite movement between price and volume. |
| sweep | bool | Liquidity sweep / fake breakout | `0` = false, `1` = true | wick > 50% of ATR | `0` | `DetectSweep` tests whether candle wicks exceed a percent of ATR. |
| ob_retest | bool | Order Block retest / trap | `0` = false, `1` = true | n/a | `1` | `DetectOBRetest` checks if price breaks a prior high/low then closes back inside. |
| candle_strength | enum | Candle momentum strength | `0`=STRENGTH_NONE, `1`=STRENGTH_WEAK, `2`=STRENGTH_STRONG | body/range > 0.3 (weak), >0.6 (strong) | `2` | `GetCandleStrength` measures body size relative to total range. |
| dir | enum | Candle direction | `0`=DIR_NONE, `1`=DIR_BULL, `2`=DIR_BEAR | n/a | `1` | `GetCandleDirection` compares close vs. open price. |
| session | enum | Market session context | `0`=SESSION_UNKNOWN, `1`=SESSION_ASIA, `2`=SESSION_EUROPE, `3`=SESSION_US | n/a | `3` | `GetMarketSession` derives the session from bar time hour. |
| news_flag | bool | News event flag | `0` = false, `1` = true | n/a | `0` | `IsNewsEvent` placeholder to mark major economic news. |
| mtf_signal | int | Multi time frame cross‑check signal | numeric code | n/a | `5` | Bitmask from H1 BOS, H1 trend, and M5 volume spike. |
| regime | enum | Classified market regime | `0`=REGIME_UPTREND, `1`=REGIME_DOWNTREND, `2`=REGIME_STABLE_RANGE, `3`=REGIME_VOLATILE_RANGE, `4`=REGIME_BREAKOUT, `5`=REGIME_TRAP, `6`=REGIME_DRIFT, `7`=REGIME_CHAOS, `8`=REGIME_UNKNOWN | n/a | `0` | `DetectRegime` evaluation of other fields. |

## Sample Data

### JSON
```json
{"time":1623495600,"symbol":"EURUSD","open":1.1000,"high":1.1050,"low":1.0980,"close":1.1020,"tick_volume":150,"bos":1,"trend_dir":0,"range_compression":0,"volume_spike":1,"divergent":0,"sweep":0,"ob_retest":1,"candle_strength":2,"dir":1,"session":3,"news_flag":0,"mtf_signal":5,"regime":0}
{"time":1623495660,"symbol":"EURUSD","open":1.1020,"high":1.1060,"low":1.0990,"close":1.1030,"tick_volume":120,"bos":0,"trend_dir":1,"range_compression":1,"volume_spike":0,"divergent":0,"sweep":0,"ob_retest":0,"candle_strength":1,"dir":2,"session":1,"news_flag":0,"mtf_signal":3,"regime":2}
{"time":1623495720,"symbol":"EURUSD","open":1.1030,"high":1.1070,"low":1.1000,"close":1.1010,"tick_volume":130,"bos":0,"trend_dir":2,"range_compression":0,"volume_spike":0,"divergent":1,"sweep":1,"ob_retest":0,"candle_strength":0,"dir":0,"session":2,"news_flag":1,"mtf_signal":2,"regime":8}
```

### CSV
```
time,symbol,open,high,low,close,tick_volume,bos,trend_dir,range_compression,volume_spike,divergent,sweep,ob_retest,candle_strength,dir,session,news_flag,mtf_signal,regime
1623495600,EURUSD,1.1000,1.1050,1.0980,1.1020,150,1,0,0,1,0,0,1,2,1,3,0,5,0
1623495660,EURUSD,1.1020,1.1060,1.0990,1.1030,120,0,1,1,0,0,0,0,1,2,1,0,3,2
1623495720,EURUSD,1.1030,1.1070,1.1000,1.1010,130,0,2,0,0,1,1,0,0,0,2,1,2,8
```

## Field Version/Change Log
| Date | Field Name | Change Description |
| --- | --- | --- |
| 2025-06-13 | RegimeFeature struct | Initial implementation of all fields and indicator logic. |
| 2025-06-14 | Added price metadata | Added time, symbol, OHLC and tick_volume fields. |
| 2025-06-15 | regime | Added regime classification field and DetectRegime logic. |
