# UNIQLO × Akamai "PEACE FOR ALL" T-shirt

I got a T-shirt from the UNIQLO **PEACE FOR ALL** collection as a Christmas present. The design by Akamai has a block of code printed on the back. This repository decodes it safely and explains what it does.

<p align="center"><img src="images/tshirt.jpg" alt="Back of the T-shirt with the printed bash script" width="420"></p>

## What's printed on the shirt

The shirt carries a one-line bash script:

```bash
#!/bin/bash
eval "$(base64 -d <<< 'IyEvYmluL2Jhc2gKCiMgQ29uZ3Jhd...')"
```

It decodes a base64 string and runs the result with `eval`. Running code you can't read is exactly how malware works, so the first step is to look inside without executing anything. As a bonus, some characters in the printed block are highlighted in orange: read in order, they spell **PEACE FOR ALL**.

## Decoding it safely

```bash
./decode.sh
```

[`decode.sh`](decode.sh) extracts the base64 payload from the [transcribed script](original/tshirt-code.sh) and prints it without running it. The output is saved in [`original/decoded.sh`](original/decoded.sh). It begins with an easter-egg greeting in English and Japanese:

```bash
# Congratulations! You found the easter egg! ❤️
# おめでとうございます！隠されたサプライズを見つけました！❤️
```

## What the code does

The decoded script is a small terminal animation. In an endless loop it:

1. takes the next character of `♥PEACE♥FOR♥ALL♥…`;
2. computes a horizontal position as `cols/2 + cols/4 · sin(0.2 · t)`, so the letters swing left and right in a wave;
3. picks a 256-color ANSI code that shifts at every line;
4. prints that single character and moves to the next line, so the message scrolls down the screen.

It hides the cursor while running and restores it on <kbd>Ctrl</kbd>+<kbd>C</kbd>.

## Repository structure

```
original/
├── tshirt-code.sh   The script as printed on the shirt
└── decoded.sh       The decoded payload
decode.sh            Safe decoder (prints, never runs)
images/tshirt.jpg    Photo of the shirt
```

The original script belongs to its authors (UNIQLO and Akamai) and is included here for documentation.
