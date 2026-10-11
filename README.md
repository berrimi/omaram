# omaram

A RAM usage ring for the Omarchy bar. Memory usage is drawn as a circular
progress arc, the tooltip shows used / total GiB, and clicking opens `btop`.

## Requirements

- Omarchy (Quattro shell)
- [`btop`](https://github.com/aristocratos/btop) for the click action

## Install

```bash
omarchy plugin add https://github.com/berrimi/omaram --enable
```

If you skip `--enable`, enable it and pick a bar placement afterwards:

```bash
omarchy plugin enable io.github.berrimi.omaram
```

## Remove

```bash
omarchy plugin remove io.github.berrimi.omaram
```

## Notes

- Usage is sampled from `/proc/meminfo` every 2 seconds.
- The ring turns accent-colored at 80% and switches to the urgent color with a
  pulsing dot at 92%, dropping back at 88% (hysteresis so it does not flicker).
- The plugin reads system memory only and writes no configuration.

## License

MIT — see [LICENSE](LICENSE).
