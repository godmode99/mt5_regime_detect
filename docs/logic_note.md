# Logic Notes

The following sections summarize the algorithms used by each indicator and outline the overall Expert Advisor workflow.

## Indicator Algorithms

### Break of Structure (BOS)

The `DetectBOS` functions check whether the current candle breaks above or below previous swing levels.

1. Look back over the last three bars to determine the highest high and lowest low.
2. BOS is **true** if:
   - `current_high > highest_previous_high`, **or**
   - `current_low  < lowest_previous_low`.

### Sweep (Liquidity Grab)

`DetectSweep` evaluates if the candle wicks exceed a fraction of the candle's range (ATR approximation).

1. Compute `atr = high - low` for the bar.
2. Calculate upper and lower wick length using `close` price.
3. If either wick is greater than **50% of ATR**, the bar is considered a sweep.

### Volume Spike

`DetectVolumeSpike` flags unusually high tick volume.

1. Calculate the average volume of the previous 20 bars.
2. If the current volume is greater than **1.5 ×** this average, `volume_spike` is **true**.

### mtf_signal

Multi time frame aggregation combines higher‑timeframe structure and lower‑timeframe volume confirmation using `AggregateMTFSignal`.

| Bit | Description |
| --- | ----------- |
| `1` | H1 Break of Structure detected |
| `2` | H1 trend direction is up |
| `4` | M5 volume spike present |

The final signal is a bit mask where multiple conditions may be active simultaneously.

### IsNewsEvent

Uses the built‑in economic calendar to detect high importance events within ±30 minutes of the bar time. Returns **true** when at least one such event is found for the symbol's base currency.

### Regime Classification

`DetectRegime` maps the calculated features to a `RegimeType` enum:

| Regime | Rule |
| --- | --- |
| `REGIME_UPTREND` | `trend_dir` = TREND_UP and not `range_compression` |
| `REGIME_DOWNTREND` | `trend_dir` = TREND_DOWN and not `range_compression` |
| `REGIME_STABLE_RANGE` | `range_compression` = true and `volume_spike` = false |
| `REGIME_VOLATILE_RANGE` | `range_compression` = true and `volume_spike` = true |
| `REGIME_BREAKOUT` | `bos` = true and `sweep` = false |
| `REGIME_TRAP` | `ob_retest` = true |
| `REGIME_DRIFT` | no momentum, no volume spike and `trend_dir` = TREND_NONE |
| `REGIME_CHAOS` | `bos`, `sweep` and `volume_spike` all true |
| `REGIME_UNKNOWN` | none of the above conditions |

## EA Workflow

1. **Initialization (`OnInit`)**
   - Reset counters and allocate a feature buffer of size `EXPORT_INTERVAL`.
2. **Per Bar Processing (`OnTick`)**
   - Exit early until a new bar forms.
   - For each of the last `HISTORY_BARS` bars call `ProcessBar` to fill a `RegimeFeature` struct.
   - Validate with `ValidateFeature`. Invalid rows are skipped.
   - Store valid features in the buffer and export once the buffer reaches `EXPORT_INTERVAL` entries.
3. **Deinitialization (`OnDeinit`)**
   - Any remaining features are exported before shutdown.

Every field is derived from indicator logic only—no manual input. This dataset can be used for machine learning or further automation.
