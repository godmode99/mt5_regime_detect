# Logic Notes

Additional notes about indicator logic and workflow will be documented here.

Current implementation validates every `RegimeFeature` using
`ValidateFeature` immediately after calculation. Invalid values are logged and
omitted from export buffers.
