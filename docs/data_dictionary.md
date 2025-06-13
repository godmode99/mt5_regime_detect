# Data Dictionary

Field | Type | Description
--- | --- | ---
bos | bool | Break of Structure flag
trend_dir | enum | Trend direction
range_compression | bool | Sideway compression or expansion detection
volume_spike | bool | Volume spike confirmation
divergent | bool | Volume divergence
sweep | bool | Liquidity grab or fake breakout
ob_retest | bool | Order Block retest or trap
candle_strength | enum | Candle momentum strength
dir | enum | Candle direction
session | enum | Market session context
news_flag | bool | News event flag
mtf_signal | object | Multi time frame cross-check signal

All fields are auto-calculated strictly by logic. No manual adjustment.
