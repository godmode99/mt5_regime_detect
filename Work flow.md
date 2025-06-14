Work Flow สำหรับ Block นี้ (mt5 > multi indicator EA > export > raw csv)

1. Data Collection (MT5)
   ดึงข้อมูล OHLCV, price, volume, หรือ indicator raw data จาก MT5 platform ตาม timeframe/condition ที่ต้องการ

2. Multi Indicator Processing (ใน EA)
   EA (Expert Advisor) จะประมวลผลข้อมูลเหล่านั้น

รวม indicator หลายตัว (เช่น trend, volatility, volume, sweep, candle pattern, session/context, news flag, mtf signal ฯลฯ)

สร้างฟีเจอร์/สัญญาณหลากหลาย field สำหรับแต่ละแท่งเทียน (แต่ละบาร์)

3. Export / Reporting
   ผลลัพธ์ feature set (แต่ละบาร์/ช่วงเวลา) จะถูก export/report ออกมาจาก EA

ฟอร์แมตที่นิยม: CSV (comma separated), บางทีเป็น json หรือ db (แต่ block นี้คือ csv)

4. Raw Data Output (CSV)
   ไฟล์ .csv ที่ได้ (raw data แต่ละแหล่ง)

1 row = 1 bar (หรือ 1 period)

column = OHLCV + indicator ทุกตัว + meta info (เช่น timestamp, symbol, session, news flag, regime ฯลฯ)

ไฟล์นี้พร้อมใช้เป็น input สำหรับ block downstream
เช่น merge, AI/ML, rules, validation, หรือ backtest

TL;DR สรุป flow สั้นๆ
scss
คัดลอก
แก้ไข
MT5 (OHLC/indicator)
└──→ EA (รวม indicator หลายตัว)
└──→ Export feature set (csv/report)
└──→ Raw data table (csv) สำหรับ downstream ต่อ
Dev Note
ถ้า design ดี: csv จะมี structure มาตรฐาน, field ครบ, ไม่มี missing/null, มี header

ถ้า AI/process downstream ใช้ต่อ จะ maintain ง่าย, debug ง่าย, cross-check regime/signal ได้หมด

Basic Regime Type (ถ้าไม่สนข่าว)
Trend (Uptrend/Downtrend)

Range/Sideway (Stable/Volatile)

Breakout/Expansion

Trap/Stop Hunt

Low Volatility Drift

High Volatility Chaos

Unknown/No Regime

1. Trend
   Uptrend:

Higher High/Higher Low, BOS ขึ้น, price > EMA, RSI/MA slope up

Downtrend:

Lower Low/Lower High, BOS ลง, price < EMA, RSI/MA slope down

2. Sideway/Range
   Stable Sideway:

ATR/Stddev ต่ำ, range_compression จริง, ราคา oscillate ในแคบๆ

Volatile Sideway:

ATR/Stddev ปานกลางถึงสูง, swing fake หลายรอบ, HH/LL ไม่ชัด

3. Breakout/Expansion
   ATR/Stddev spike ขึ้นอย่างเร็ว, ราคา breakout จาก range ที่นาน

volume spike + HH/LL ใหม่

4. Trap/Stop Hunt
   wick ใหญ่, sweep high/low แล้วราคากลับมาใน range เดิม

false breakout, volume spike แล้ว fail

5. Low Volatility Drift
   ATR/Stddev ต่ำผิดปกติ, candle เล็กต่อเนื่อง, ไม่มี momentum

sideway แต่บางทีลากยาวๆแบบ “หลับ”

6. High Volatility Chaos
   ATR/Stddev สูงมาก, candle/volume spike ถี่, ทิศทางมั่ว

7. Unknown/No Regime
   หากไม่มีสัญญาณตรงกับกฎด้านบน

Indicator ที่ควรใช้
Structure/Trend: HH, HL, LL, LH, BOS, trend_dir (enum), MA/EMA slope

Range/Volatility: ATR, Stddev, true range, range_compression (bool)

Volume: volume_spike, avg_volume, OBV, MFI, divergence

Momentum: RSI, momentum, candle_strength, engulf, directional index

Trap/Sweep: wick size, sweep (bool), OB retest, trap/fake

Session/Context: session (optional)
