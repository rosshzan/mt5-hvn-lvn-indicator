# MT5 HVN/LVN Open-Close Indicator

This project contains a simple MT5 indicator that marks High Volume Nodes (HVN) and Low Volume Nodes (LVN) for selected dates using the market open-to-close session window.

## What it does

For each date listed in the input parameter `DateList`, the indicator scans all bars from the first bar of that calendar date through the last bar of that date and identifies:

- HVN: the bar with the highest volume within that date's session window
- LVN: the bar with the lowest volume within that date's session window

The indicator then places chart labels on the relevant bars so you can visually review notable volume events.

## Input parameters

- `DateList`: comma-separated list of dates to scan, for example:
  - `2026.01.02,2026.01.05,2026.01.06`
- `ShowHVN`: enable/disable HVN labels
- `ShowLVN`: enable/disable LVN labels
- `HVNColor`: label color for HVN
- `LVNColor`: label color for LVN

## Installation

1. Open MetaEditor in MT5.
2. Create a new indicator.
3. Copy the contents of `HVN_LVN_OpenClose_Indicator.mq5` into the editor.
4. Compile the code.
5. Attach the indicator to a chart.
6. Update the `DateList` parameter with the dates you want to monitor.

## Typical usage

This is useful when you want to quickly isolate the single highest-volume and lowest-volume bars during a specific market session on a small set of dates, such as:

- key economic events
- earnings windows
- macro release dates
- custom backtest reference dates

## Notes

This implementation uses the calendar date as the evaluation period, so the market open and close are treated as the first and last bar on each selected date in the current chart timeframe. If you want a stricter session rule (for example, a custom market open time such as 09:30 and close at 17:00), the logic can be expanded to use session time filtering.

## Disclaimer

This is a research and charting tool for educational use. It is not financial advice or a guarantee of trading performance.
