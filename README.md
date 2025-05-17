# VIC-II Kawari

**IMPORTANT PSA! The v1.17 firmware on some Kawari large boards shipped around Sept 2023 from VGP contained a bug causing DVI video instability. If you received one of these devices, please flash the updated v1.17 firmware from the [FIRMWARE](doc/FIRMWARE.md) page to correct the issue. I apologize for the inconvenience. Refer to [FLASHING](doc/FLASHING.md) for instructions on how to update the firmware.**

## What is VIC-II Kawari?
VIC-II Kawari is a hardware replacement for the VIC-II (Video Interface Chip II) found in Commodore 64 home computers. In addition to being compatible with the original VIC-II 6567/6569 chips, some extra features are also available. See [REGISTERS.md](doc/REGISTERS.md)

This repository contains an open source VIC-II FPGA core written in Verilog. Three PCB designs/configurations are possible ranging from (approximately) $30 BOM cost to $80 BOM cost.

The PCB interfaces with a real C64 address and data bus through the VIC-II socket on the C64 motherboard. The board can replace all the functions of a real VIC-II chip including DRAM refresh, light pen interrupts (real CRT only), PHI2 clock source for the CPU and, of course, video output.

See [Compatible Motherboard Revisions](#what-motherboard-revisions-will-this-fit) for information about installation.

## Resources

[Utility and Demo Disks](http://accentual.com/vicii-kawari/downloads/prog) - Utilty and demo disk download area<br>
[Discord Server](https://discord.gg/KZcRBfZh8z) - Chat about stuff, ask questions<br>
[Report Issues](https://github.com/randyrossi/vicii-kawari/issues) - File bugs/issues<br>

[Firmware Download Links](doc/FIRMWARE.md) | [Flashing Guide](doc/FLASHING.md) | [Jumpers](doc/VARIANTS.md) | [Programming](doc/REGISTERS.md)

## What kind of video output options are there?

Please note that the video options available depends on the board design and configuration:

Board Design | DVI | Analog RGB | Luma/Chroma | Extensions/Switching
-------------|-----|------------|-------------|---------------------
Kawari-Large | Yes | Yes        | Yes         | Yes
Kawari-Mini  | No  | No         | Yes         | Yes

For a chart breaking down all features available or missing for a particular board design, please see [MODELS.md](doc/MODELS.md)

Video Option | Connector  | Notes
-------------|------------|-------
DVI          | Micro HDMI |User must fish cable out of machine and provide strain relief
Analog RGB   | Analog Header |User must build custom RGB connector, fish cable out of machine and provide strain relief, RGB:.7Vp-p (75 ohm termination) HV:TTL
Luma/Chroma  | A/V Jack   |Regular S/LUM output at rear of computer (composite or s-video)

The core is flexible and can be configured to support all three or any subset of these video options provided the hardware can support it.

By default, the DVI/RGB signals double the horizontal frequency from ~15.7khz to ~31.4khz (for 2X native height). The horizontal resolution is also doubled to support the 80 column mode.  The spartan boards support turning off scaling for both DVI and RGB output.  The Trion boards (DVI) no longer support 1x scaling (either width/height). (NOTE: Turning off horizontal scaling will prevent hires modes from working properly.)

### Trion Large Board DVI Options

There are two firmware options for DVI output on the Trion boards but there are trade-offs to be aware of.

Firmware | Variant Code | Trade-off
---------|--------------|----------
Default  | DVI          | Less visible border area esp. for NTSC chips. Less compatible PAL mode.  Some monitors won't display it.  However, you get fully defined hires (80 column and 640x200) modes
Scaled   | DVS         | More visible border area for NTSC chips. More compatible PAL mode. However, you will get pixelated hires (80 column and 640x200) modes as the output is scaled.  Regular C64 video modes will still look fine.

If you are not interested in the extended features and are having trouble with the PAL mode on your monitor, try the alternate firmware.  The modes are summarized below:

#### Trion Large Board DVI (Default)

The default DVI firmware (full 2x/2Y resolution) is reduced to the following values:

Video        |Sx|Sy|Vis. Width  |Vis. Height|Horiz Freq |Vert Freq  |Pixel Clock
-------------|--|--|------------|-----------|-----------|-----------|-----------
NTSC         |2x|2x|740         |500        |31.46khz   |59.82hz    |26.590 Mhz
NTSC(Old)    |2x|2x|736         |498        |31.96khz   |60.99hz    |26.590 Mhz
PAL-B        |2x|2x|782         |576        |31.26khz   |50.125hz   |29.557 Mhz

Video        |Sample|Notes
-------------|------|------
NTSC         |![NTSC Scaled](doc/images/6567R8-26MHZ-U.png "NTSC Scaled")|Less border area but new hires modes fully defined. Non-standard resolution may confuse some monitors.
NTSC(Old)    |![NTSC(Old) Scaled](doc/images/6567R8-26MHZ-U.png "NTSC Scaled")|Less border area but new hires modes fully defined. Non-standard resolution may confuse some monitors.
PAL-B        |![PAL Scaled](doc/images/6569-29MHZ-U.png "PAL Scaled")|Less compatibility but new hires modes fully defined. Non-standard resolution may confuse some monitors.

If your monitor does not support the non-standard PAL-B mode, see 'Alternate Trion DVI Firmware' below.

#### Alternate Trion DVI Firmware (Scaled)

The default Trion DVI firmware may not work on all monitors/TVs as it outputs resolutions that are not standard.  Also, the video tends to be more 'stretched' even using a 4:3 aspect ratio setting on the monitor.  If your display doesn't show the PAL video mode, you can try an alternate DVI firmware with a mode closer to the 720x576 standard. This is more likely to work for older TVs/monitors.  However, please be aware the C64's native video modes are scaled by 1.8x rather than 2x to get a better aspect ratio and more border space. Although regular C64 video modes will look okay, the Kawari's extended hi-resolution modes (80 column, 640x200) will look pixelated as those modes are effectively downscaled 10:9. This an unfortunate trade-off to using this video timing.

Video        |Sx  |Sy|Vis. Width  |Vis. Height|Horiz Freq |Vert Freq  |Pixel Clock
-------------|----|--|------------|-----------|-----------|-----------|-----------
NTSC         |1.8x|2x|720         |480        |31.46khz   |59.82hz    |26.590 Mhz
NTSC(Old)    |1.8x|2x|724         |480        |31.96khz   |60.99hz    |26.590 Mhz
PAL-B        |1.8x|2x|720         |576        |31.26khz   |50.125hz   |27.586 Mhz

Video        |Sample|Notes
-------------|------|------
NTSC         |![NTSC Scaled](doc/images/6567R8-26MHZ-S.png "NTSC Scaled")|More border area but new hires modes will look pixelated. Regular C64 video modes not affected by scaling. More compatible resolution.
NTSC(Old)    |![NTSC(Old) Scaled](doc/images/6567R8-26MHZ-S.png "NTSC Scaled")|More border area but new hires modes will look pixelated. Regular C64 video modes not affected by scaling. More compatible resolution.
PAL-B        |![PAL Scaled](doc/images/6569-27MHZ-S.png "PAL Scaled")|Better compatibility but new hires modes will look pixelated. Regular C64 video modes not affected by scaling. More compatible resolution.

### Analog RGB Output

Video        |Sx|Sy|Width|Height|Horiz Freq |Vert Freq  |Pixel Clock
-------------|--|--|-----|------|-----------|-----------|-----------
NTSC         |1x|1x|520  |263   |15.73khz   |59.82hz    |8.181 Mhz  
NTSC(Old)    |1x|1x|512  |262   |15.98khz   |60.99hz    |8.181 Mhz  
PAL-B        |1x|1x|504  |312   |15.63khz   |50.125hz   |7.881 Mhz  
NTSC         |2x|1x|1040 |263   |15.73khz   |59.82hz    |16.363 Mhz 
NTSC(Old)    |2x|1x|1024 |262   |15.98khz   |60.99hz    |16.363 Mhz 
PAL-B        |2x|1x|1008 |312   |15.63khz   |50.125hz   |15.763 Mhz 
NTSC         |1x|2x|520  |526   |31.46khz   |59.82hz    |16.363 Mhz 
NTSC(Old)    |1x|2x|512  |524   |31.96khz   |60.99hz    |16.363 Mhz 
PAL-B        |1x|2x|504  |624   |31.26khz   |50.125hz   |15.763 Mhz 
NTSC         |2x|2x|1040 |526   |31.46khz   |59.82hz    |32.727 Mhz 
NTSC(Old)    |2x|2x|1024 |524   |31.96khz   |60.99hz    |32.727 Mhz 
PAL-B        |2x|2x|1008 |624   |31.26khz   |50.125hz   |31.527 Mhz 

FYI: The older Spartan6 board DVI firmware has resolutions identical to the spartan table above.

The unpopulated 10 pin analog header at the top of the board (1 +5V, 6 signal, 3 GND) can wired to a monitor with a custom built cable.

    +5V CLK GND RED GRN
    GND VSY HSY BLU GND

For 1080/1084-D monitors, a CSYNC option can be enabled to output composite sync over the horizontal sync pin.  1084-S monitors use the default separated HSYNC and VSYNC signals.

NOTE: The CLK pin (dot clock) can be used to export the dot clock back into the motherboard if the clock circuit has been disabled. This is only necessary for some specialty cartridges that need an in-sync dot clock to function.  It is not necessary for analog connections to monitors.

#### FEMALE 6-PIN PORT AS VIEWED FROM REAR OF 1084-S

       _______       Pin#      Signal
      /   3   \      Pin 1     G  Green
     / 2     4 \     Pin 2     HSYNC Horizontal Sync
    |     6     |    Pin 3     GND Ground
     \ 1  _  5 /     Pin 4     R  Red
      \__/ \__/      Pin 5     B  Blue
                     Pin 6     VSYNC Vertical Sync

#### MALE 9-PIN PORT AS VIEWED FROM REAR OF 1080/1084-D (Analog RGB Mode)

                     Pin  Name     Signal
    _____________     1   GND      Ground
    \ 1 2 3 4 5 /     2   GND      Ground
     \_6_7_8_9_/      3   R        Red
                      4   G        Green
                      5   B        Blue
                      6   I        not used
                      7   CSYNC    Composite Sync (Enable CSYNC option in config)
                      8   HSYNC    not used
                      9   VSYNC    not used

    The x2 native width video modes work on 1080/1084 monitors (requred for 80 column/hires modes).

A SCART adapter should be possible but has not been built/tested.

## How can I find out if my DVI/HDMI monitor supports the video modes?

You can try the xrandr helper scripts inside [monitor_tests](util/monitor_tests) directory in this repository.  These are scripts meant to test the 60hz/50hz modes from your Ubuntu Linux machine. See [README.md](util/monitor_tests/README.md) for a description on how to use them.

## DVI limitations

### DVI Limitations Summary

1. May not work on older monitors or TVs (non-standard resolutions)
2. You won't get a 4:3 aspect ratio unless your display has the option
3. You may have to turn off the display or use an HDMI switch to boot the C64
4. Using the motherboard oscillator may result in loss of sync

### DVI Limitations Details

1. The resolution/timing the board outputs is not a standard resolution.  Some older TVs/monitors may not sync to it.  Some HD Capture cards only accept standard resolutions as well (like 720p or 1080p) and will also not sync.

2. The display will be horizontally stretched on most HDMI displays.  You will not be able to get a perfect 4:3 aspect ratio.  Some displays have a aspect ratio option that can yield a better result. There are no plans to do any processing on the output (i.e. scaling).

3. HDMI monitors can power the FPGA core through the HDMI cable.  This prevents the core from booting properly (or sometimes booting at all).  It's an unwanted side-effect of driving the TMDS lines directly from the FPGA core.  This device is not an HDMI device, it is DVI over an HDMI connector. A buffer IC is required to avoid this but would add more cost to the board. The work around is to either power off the monitor or use an HDMI switch.

4. The quality of the mother board clock is not sufficient to derive the 40x dot clock required for the DVI signals.  It appears the high jitter on the crystal is the cause.  The motherboard clock was never meant to go through a clock multiplier to high frequencies.  This appears to cause sync loss especially on NTSC boards.  For this reason, the on-board oscillators should be used to drive the digital display modes.

## What chip models can this replace?
The 'Large' and 'Mini' models can replace the 6567R8(NTSC),6567R56A(NTSC),6569R3(PAL-B),6569R1(PAL-B) models. They can assume the functionality of either video standard with a simple configuration change followed by a cold boot. This means your C64 can be both an NTSC and PAL machine. (PAL-N / PAL-M are not supported but it can be added with some hardware modifications.)

## What motherboard revisions will this fit?
The 'Mini' boards will fit into revisions 250407, 250425, 326298 & KU-14194HB. For 250425 boards, the RF sheild must be removed. For 250407, 326298 and KU-14194HB, the 'top' cover of the RF sheild compartment must be removed.

The 'large" board will fit into revisions 250407, 250425, 326298 & KU-1419HB provided an extra socket is included to give the PCB enough height to clear some of the clock circuit components.  However, if present, the RF sheild surrounding the video circuitry will prevent an HDMI cable from being plugged in even with an extra socket.  For better HDMI port access, the large board is recommended for boards that do not have an RF sheild surrounding the video circuit.  Also, it is better if the RF modulator is unpopulated or replaced with a RF modulator bypass board.  This leaves room for a cable to be plugged in and exit the machine through unused holes at the back.  Strain relief is up to the user.

## Will this work in C64-C (short board) models with 250466/250469?

I don't recommend the Kawari for motherboards inside C64-C cases and especially the 250469 revisions. See below for more details.

NOTE: The VDD pin is not connected so there is no voltage compatibility issue like with the real 8562/8565 models. It won't damage the Kawari to plug it into a C64-C 'short' board. You may run into the issues described below, however.

### 250466 inside C64-C cases

It is difficult to close the machine. The 'Mini' PCB sits too high off the motherboard which presses up on the sheilding (required to be installed due to keyboard support brackets being attached).  The large also requires an extra socket to clear some motherboard components and causes the same issue with the sheild. If you are willing to replace the sheild with 3D printed keyboard support brackets (or other solutions), you may be able to get it to fit into a closed machine. However, this has not been tested.  There are no known compatibility issues with this revision so if you place it into a breadbin case, it will likely work fine for you.  The C64-C case / keyboard is the main issue.

### 250469 (in any case)

The same space/fit issues exist as with the 250466 board in C64-C cases but there are two additional problems that occur regardless of case:

1. The SuperPLA will hold the NMI line low due to a startup glitch. The precise cause of the glitch is not known but it is believed to be related to the time the Kawari takes to load the bitstream into the FPGA.  During this time, the clock is effectively decoupled from the bus and there is nothing to drive the signal high or low.  The SuperPLA took over the responsibility of the RESTORE key triggering NMI low.  However, more often than not, it gets stuck LOW on power up even after the clock signal eventaully starts.  This will cause any program that expects NMI from the CIA timer to not get triggered.  It appears the only way to get it 'unstuck' is to pulse the RESTORE input to the SuperPLA.  

    Workarounds:

    1. You can run a jumper wire from the Kawari's RST pad (located in the top left) to the RESTORE line where resistor R17 and C59 meet or on Pin 11 of U23 or pin 9 of the PLA U8. This involves soldering a wire to the Kawari pad.
    2. Or....You can simply tap the RESTORE key on the keyboard after a cold boot. This effectively 'kicks' the SuperPLA to stop driving the NMI line low.
    3. Or....You can replace the SuperPLA with a modern replacement such as [u251715 64 MMU](https://uni64.com/shop/index.php?find=u251715%2B64+MMU) from uni64.com (which appears to not exhibit the startup glitch as a genuine chip does)

    Any one of the workarounds listed above will avoid the issue.

2. The SuperPLA became gatekeeper for DRAM WE signal and does not allow DRAM to be go LOW during the VIC2's cycle.  This means the extended feature of DMA transfers from video memory to DRAM do not function on the 250469 without a hardware modification.  This is not a concern unless you are running a Kawari specific application/demo that wants to use that extended feature.  This limitation does not affect 'regular' C64 programs in any way.  If you want to allow the Kawari to write to DRAM, wire a jumper either from Pin 6 of U6 on the Kawari or Pin 11 of the VIC2 to the WE pin of one of the LH2464 DRAM chips.  U6 is the SN74LS05D located in the top left of the Kawari.  Note the orientation of U6 on the mini is opposite that of the large but the pin # to use is the same between them.

## What about EVO64 boards?
There appear to be no issues on EVO64 boards, however I do not have one to test and rely on the community to report problems.

## What about MK/MK2 Reloaded Boards?
The Kawari is NOT compatible with the MK/MK2 Reloaded boards.

## Isn't the quality of 6567R56A composite video bad?
The 6567R56A composite signal is known to be worse than the 6567R8. The cycle schedule (and hence timing) is slighly different in the 6567R56A. It generates a signal slightly out of range from the expected 15.734khz horizontal frequency for NTSC (it generates 15.980khz instead). Some composite LCD monitors don't like this and even the real chips produced unwanted artifacts on those types of displays. You will get the same unwanted artifacts from a VIC-II Kawari producing composite video when configured as a 6567R56A. Most CRTs, however, are more forgiving and you may not notice the difference. Some TVs still show a bad picture. When using DVI or RGB output, this is of no concern as long as your monitor can handle the frequency (the image will look just as good as any other mode). There may be _some_ NTSC programs that depend on 6567R56A to run properly due to the cycle schedule but I'm not aware of any.  The default config defines only 5 luminance levels for the 6567R56A.

## What about the 6569R4/R5?
There are subtle differences between the PAL-B revisions mostly to do with luminance levels. I included the 6569R1 as an option.  Keep in mind the default luma config has only 5 luminance levels instead of 8 and also has a light pen irq trigger bug. (There's nothing stopping you from defining 8 lumanance levels for the 6569R1 though).

## What about the 6572?
It is, in theory, possible to re-purpose one of the video standards to be a 6572 (South America PAL-N). It would require a firmware change and the board would have to be configured to use the motherboard's clock (or one of the oscillators changed to match PAL-N frequency).  Either NTSC or PAL-B could be replaced with PAL-N. As far as I can tell, the only reason to do this would be to get real Argentinian CRTs/TVs to display a composite signal correctly while being (mostly) compatible with NTSC software. (This is a lower priority project but if someone else wants to take on the challenge, it could appear as a fork.)

## Do I need a functioning clock circuit on my motherboard?
This depends on how the VIC-II Kawari PCB has been populated and configured. The 'Large' and 'Mini' boards come with on-board oscillators for both NTSC and PAL-B standards. In that case, the motherboard's clock circuit can be bypassed. However, the board can be configured to use the motherboard's clock for the machine's 'native' standard via jumper config. In that case, one of the two video standards can be driven by the motherboard's clock.  Please see [Limitations/Caveats](#limitationscaveats) below regarding pin 6 of the cartridge port. Refer to the table below for C.SRC jumper settings.

## How do the C.SRC jumpers work?

For 'Large' and 'Mini' boards, the C.SRC jumpers let you select the clock source for the two video standards the board supports. By default, both video standards are driven by on-board oscillators (if the board has been populated with them).  However, you have the option of using the machine's 'native' clock source for one of the video standards.  This is an option in case some specialty cartridges require the use of Pin 6 on the cartridge port. See [Limitations/Caveats](#limitationscaveats)

Here is a table describing the valid jumper configurations:

PAL-B Jumper | NTSC Jumper | Description
:--------:|:--------:|------------
<span style="font-family:fixed;line-height:1em;">█<br><br>█<br>│<br>█</span>|<span style="font-family:courier;line-height:1em;">█<br><br>█<br>│<br>█</span>|Uses on-board oscillators for both video standards.  Some specialty cartridges using Pin 6 of cartridge port may not work.

PAL-B Jumper | NTSC Jumper | Description
:--------:|:--------:|------------
<span style="font-family:fixed;line-height:1em;">█<br>│<br>█<br><br>█</span>|<span style="font-family:courier;line-height:1em;">█<br><br>█<br>│<br>█</span>|Uses on-board oscillator for NTSC, motherboard clock for PAL-B.  Board will only work in PAL-B mode on a PAL-B machine. Some specialty cartridges using Pin 6 of cartridge port may not work in NTSC mode.

PAL-B Jumper | NTSC Jumper | Description
:--------:|:--------:|------------
<span style="font-family:fixed;line-height:1em;">█<br><br>█<br>│<br>█</span>|<span style="font-family:courier;line-height:1em;">█<br>│<br>█<br><br>█</span>|Uses on-board oscillator for PAL-B, motherboard clock for NTSC. Board will only work in NTSC mode on a NTSC machine.  Some speciality cartridges using Pin 6 of cartridge port may not work in PAL-B mode.


## Do I need to modify my C64 motherboard?
The board will function without any modifications to the motherboard. If you can find a way to get a video cable out of the machine, there is no reason to modify the machine. However, it is much easier if the RF modulator is removed. The hole previously used for the composite jack may then be used for an HDMI or VGA cable. Otherwise, there is no practical way for a video cable to exit the machine unless you drill a hole or fish the cable out the casette or user port space.

IMPORTANT! Strain relief on the cable is VERY important as it exits the machine.  No matter the solution, it is imperative the cable not be allowed to pull on the board while it is seated in the motherboard socket.

## How accurate is it?
To measure accuracy, I use the same suite of programs VICE (The Versatile Commodore Emulator) uses to catch regressions in their releases. Out of a total of 280 VIC-II tests, 280 are passing (at least by visual comparison).

I can't test every program but it supports the graphics tricks programmers used in their demos/games. Refer to the Hardware/Software compatibility matrix below. Although perhaps not perfect, it is safe to say it is a faithful reproduction of the original chips.

## Is this emulation?
That's a matter of opinion. Some people consider an FPGA implementation that 'mimics' hardware to be emulation because some behavior is being re-implemented using a high level hardware description language. But it's important to note that the PCB is not 'running' a program like you would on a PC. The PCB is providing a real clock signal to drive the 6510 CPU. It's also generating real CAS/RAS timing signals to refresh DRAM. It is interacting with the same address and data bus that a genuine chip would.

## Will digital video make my C64 look like an emulator?
Yes. The pixel perfect look on an HDMI monitor will resemble an emulator. There is an option that will render ever other line with half brightness giving a raster line effect.  This makes the picture look slightly darker though.  Other than that, there is no effort to make digital video look like a CRT. If you want the look of a CRT, you should chose the VGA or composite options and use a real CRT. Also, the resolution will not match an HDMI monitor's native resolution so there will always be some scaling taking place.

## Will DVI/VGA add delay to the video output?
There is no frame buffer for video output. However, there is a single raster line buffer necessary to double the 15khz horizontal frequency. Although this adds a very small delay, it is a tiny fraction of the frame rate and is imperceivable by a human. For DVI, any additional latency will be from the monitor you use. Most TVs have a 'game mode' that turns off extra processing that can introduce latency and it is highly recommended you use that feature.

## My DVI/HDMI monitor stretches the picture. Can that be changed?
The video signals are output at native resolution (or 2x) and since there is no frame buffer, the aspect ratio of the image cannot be adjusted. It will be up to your monitor/TV to support 4:3 aspect ratio to display something that doesn't look 'stretched'.  I have no plans on making the DVI/HDMI image look like an analog display.

## Do light pens work?
Yes. However, light pens will only work using a real CRT with composite. (LCD/DVI/HDMI or even VGA monitors will not work with light pens.)

## This is more expensive. Why not just buy a real one?
If you need a VIC-II to replace a broken one, you should just buy one off eBay. This project is for fun/interest and would certainly cost more than just buying the real thing. However, there are some advantages to using VIC-II Kawari ('Large/Mini' models):

* No 'VSP' bug
* Configurable color palette (262144 RGB color space, 262144 HSV color space)
* No need for a working clock circuit
* Can software switch between NTSC and PAL-B
* Optional NTSC/PAL-B hardware switch
* Four chip models supported (6567R56A, 6567R8, 6569R1, 6569R3)
* An 80 column mode and new graphics modes
* An 80 column Novaterm driver
* Some fun 'extras' to play around with
* It's not an almost 40 year old device that may fail at any time

Also, since the core is open source, hobbyests can add their own interesting new features (i.e. a math co-processor, more sprites, more colors, a new graphics mode, a display address translator, etc) See [FORKING.md](doc/FORKING.md) for some a list of possible add-ons.

## What extra features are available ('Large/Mini' models)?

### A configurable color palette

Each of the Commodore 64's 16 colors can be changed for preference. For RGB based video (DVI/VGA), an 18-bit color space is available (262144 colors). For composite (luma/chroma) video, a 18-bit HSV color space is available (262144 colors). The color palette can be saved and restored on a cold boot and is configurable for each chip separately.

### An 80 column text mode

A true 16 color 80 column text mode is available. This is NOT a soft-80 mode that uses bitmap graphics but rather a true text mode. Each character cell is a full 8x8 pixels. An 80 colum text screen occupies 4k of kawari video memory space (+4k character definition data). A small program (2k resident at $c800) can enable this for the basic programming environment. The basic text editor operates exactly as the 40 column mode does since the input/output routines are simply copies of the normal kernel routines compiled with new limits. This mode also takes advantage of hardware accelerated block copy/fill features of VIC-II Kawari so scrolling/clearing the text is fast.

NOTE: 40 column BASIC programs will not necessarily run without modification in the 80 column mode. If the program uses print statements exclusively, then there's a good chance it will work.  If it uses POKEs to screen memory, it will have to be modified.

NOTE: The 80 column display was not intended for TVs or low resolution monitors. The mode will function using a composite signal but the bandwidth is too low and you will not get a sharp display.  You may get a more usable image using a custom s-video cable (and possibly an upscaler).

### Novaterm 9.6c 80 column driver

A Novaterm 9.6c 80 column video driver is available.  Use this driver with a user port or cartridge modem and relive the 80's BBS experience in 80 columns on your C64!

### New graphics modes

In addition to the 80 column text mode, three bitmap modes have been added for you to experiment with:

    320x200 16 color - Every pixel can be set to one of 16 colors.
    640x200 4 colors - Every pixel can be set to one of 4 colors.
    160x200 16 colors - Every pixel can be set to one of 16 colors.

#### Notes about sprites in hires-modes

Low-res sprites will show up on the hi-res modes. However, they behave according to low-res mode rules. That means their x-positions are still low resolution. Background collisions will trigger based on hi-res screen data, but cannot detect collisions at the 'half' pixel resolution. Sprite to sprite collisions should work as expected. This was a compromise chosen between adding new hires sprite support (taking up a lot of FPGA space) and having no sprites at all.  For the 320x200 and 640x200 bitmap modes, a pixel is considered to be background if it matches the background color register value.  Otherwise, it is foreground.

### More RAM

There is an additional 64K of video ram. This is RAM that the video 'chip' can access directly for the new hires modes.  It can also be used to store data and there is a DMA transfer function that can copy between DRAM and VRAM quickly without using CPU resources.

### Hardware DIV and MUL registers

Hardware divide and multiply registers were added to avoid costly loops. Some programs can be modified to take advantage of these registers.

### Blitter/Copy/Fill

A blitter is availble to copy rectangular regions of memory quickly without using the CPU.  There are also block copy and fill routines that can move or fill video ram. These features are useful for the new hi-res modes.

### Software switch between PAL-B and NTSC

A configuration utility is provided which allows you to change the chip model at any time. Changes to the chip model will be reflected on the next cold boot. This means you can switch your C64 between NTSC and PAL-B with ease AND without opening up your machine!

The full featured config utility takes longer to load, so a smaller quick switch program dedicated to changing the chip is also included.

### Hardware switch between PAL-B and NTSC

The 'switch' header on the PCB will toggle the chip model between the saved standard (switch open) and the opposite standard (switch closed). Please note that the 'older' revisions and 'newer' revisions will switch with each other.

What's Saved  | Swith OPEN   | Switch CLOSED
--------------|--------------|--------------
6567R8 NTSC   | 6567R8 NTSC  | 6569R5 PAL-B
6567R56A NTSC | 656756A NTSC | 6569R1 PAL-B
6569R5 PAL-B  | 6569R5 PAL-B | 6567R8 NTSC
6569R1 PAL-B  | 6569R1 PAL-B | 6567R56A NTSC

## What are the installation options?

### Composite - No mod

Simply plug VIC-II Kawari into the VIC-II socket.  No modifications are necessary.

### VGA + RF Modulator Removal or Replacement

In this configuration, the RF modulator is removed or replaced with a device that continues to generate the composite signal for the video output port. The hole previously used for RF out is used for a custom VGA cable connected to the header on Kawari.

NOTE: Strain relief is important!

NOTE: You can get away without removing the RF modulator but then you will have the challenge of getting the VGA cable out of a closed machine.  I don't recommend drilling holes but this is an option. Another option is to fish the cable out the user port opening, if you don't plan on using any user port connections.

### DVI + RF Modulator Removal or Replacement

In this configuration, the RF modulator is removed or replaced with a device that continues to generate the composite signal for the video output port. The hole previously used for RF out is used for an HDMI cable connected to the Kawari.

NOTE: Strain relief is important!

NOTE: You can get away without removing the RF modulator but then you will have the challenge of getting the cable out of a closed machine.  I don't recommend drilling holes but this is an option. Another option is to fish the cable out the user port opening, if you don't plan on using any user port connections.

## Config RESET

You can reset the board by temporarily shorting the jumper pads labeled 'Reset' while the device is powered on. The background and border color will turn white to let you know a reset has been detected. Then cold boot. This will prevent the device from reading any persisted settings.  The default palette will be used for all models.  After a config reset, the next time you run any configuration utility, it will prompt you to initialize the device again.

## Can you add feature X and option Y and enhancement Z?

Not really. That's up to you. That's why the project is open source.  Consider my 'MAIN' variant one possibility of what you can do with the device.  However, since my features take up practically all the fabric, you would most likely have to disable some of my 'extras' in favor of yours.

## Why are changed colors not resetting after a cold boot (HDMI Cable)?

The FPGA can be powered by the monitor through the HDMI cable and even though the C64 is powered off, the video card continues to run and hold the most recent color register changes.  The solution is to turn off your monitor for a few seconds and then turn on the C64/monitor again.  (Or use an HDMI switch).  This only happens if you are using the extended features.  The same is true for hi-res modes.  If you find you are 'stuck' in a hires mode, you need to cold boot (for real).

## Why isn't my video standard switch working (HDMI Cable)?

Same reason as above. Kawari detects the switch only after a cold boot but if your monitor is still providing power to the board, it's not really cold booting. Workaround is described above.  The same problem will happen for other 'cold boot' settings.

## Known DVI + Monitor Issues

As noted above, the DVI resolutions used are not standard and may not sync or display properly on all monitors.  This table keeps track of known issues.

Brand   | Type    | Model             | Status
--------|---------|-------------------|-------
LG      | Monitor | 27UK850           | Monitor produces zig-zag effect for resolutions that have an odd width. Affects 6567R8, 6569R3, 6569R8.  Looking into compensating for this 'odd' behavior.
LG      | Monitor | 27GL650F          | One user reported same zig-zag problem as above but I have the same monitor and it works for me.
Samsung | Monitor | SyncMaster 2443SW | Complains with Optimimum Resolution message after 1 minute. Then goes black.
ACER    | Monitor | KA270HK           | Does not sync to DVI signal.
Sony    | TV      | KDL-40S3000       | Does not sync to DVI signal.

## Hardware Compatibility Matrix

Hardware                    | Status
----------------------------|----------------------------------
Kung Fu Flash Cartridge     | Working as of v1.5 on all long board motherboard revisions I've tested.
SuperCPU                    | Tested and works as long as the motherboard clock is used (jumper setting). Will not work with on-board oscillators (unless you have disabled the motherboard oscillator circuit and exported dot clock from the PCB back into the motherboard.)
REU                         | Untested but should works as long as the motherboard clock is used.
MK2 Reloaded                | Not supported.
The Final Cartridge         | No issues discovered so far.
Ultimate 1541               | Recent firmware may be required. (3.10j)
Pi1541                      | Must turn off GraphIEC feature or else some demos will fail (same with real VIC-II's)
Link232 Wifi Cartridge      | Works but requires motherboard clock jumper setting. Will not work with on-board oscillators (unless dot clock is exported).
Turbo Chameleon             | Reported to work with motherboard clock jumper setting.
SaRuMan DRAM Replacement    | Lyonte LY62W1024RL-55SL 2010 I220111A08W1S - Works with Kawari firmare 1.14+
SaRuMan DRAM Replacement    | ISSI IS61C1024AL-12HLI DSK493X1 2239 - There was a batch of Saruman's made with these SRAM chips and it does not work with the Kawari.  Unfortunately, my attempts to meet the different timing of this device have failed (or introduced regressions).
StrikeTerm w/ UP9600 Modem  | Must load 80col.kawari before selecting UP9600 modem
SPL HD-64 HDMI Modulator    | Must use v1.19+ firmware, previous versions did not match refresh pattern of original chip and 'confused' this product
c0pperdragon Video Mod      | Reported to work with v1.19+ firmware but unverified.

## Software Compatibility Matrix

Software                | Status
------------------------|----------
errata (emulamer)       | End screen should slow reveal but quick revelals instead. Cause unknown.
Uncensored (booze)      | Does not advance on disk 2 swap on my 326298 long board. Works on others. But loading directly from disk 2 does work and the rest of the demo plays.
Edge of Disgrace        | Some garbage at the bottom of first face pic on 326298 & 250245. Rest of demo plays fine. Problem does not happen on 250407.
Super Mario Bros Turbo Option | If Kawari extensions are enabled, Super Mario Bros will have severe slowdowns.  This is because there is a register collision and it thinks Turbo option is available even though it is not.  Solution is to just cold boot and/or disable Kawari extensions.

## Other Limitations/Caveats

### Soft Reset + HiRes Modes / Color Registers

Please note that if you change color registers or enable hi-res modes, Kawari will not revert back to the default palette or lo-res modes with a soft reset (or even RUN/STOP restore). If you want the Kawari 'Large' model to detect soft resets, you can connect the through hole pad labeled RST in the upper left corner of the board to the 6510's RESET pin (or any other RESET location) using a jumper wire and grabber.  The 'Mini' model cannot detect resets.

### Cartridges that use DOT clock pin (pin 6)

A cartridge that uses the DOT clock signal on pin 6 may not work when the clock source is set to the on-board oscillator. The signal that reaches pin 6 of the cartridge port comes from the motherboard clock circuit and will likely be out of phase/sync with the clock generated by the on-board oscillator. In this case, you can configure your Kawari to use the motherboard's 'native' clock instead of the on-board oscillator. Note, however, that only the machine's 'native' video standard will work with such a cartridge. Since the vast majority of cartridges do not use pin 6, this should not be a problem for most users. A list of cartridges that are known to have problems may appear here in the future.

### Pi1541 GraphIEC Feature

The Pi1541 has a feature that displays the IEC bus information to its display. This can interfere with tight timing requirements on some demo fast loaders (even on a genuine VIC-II chip) and can lead to corrupted data loaded into memory. If you are experiencing random crashes on demos like 'Uncensored', 'Edge of Disgrace' or similar demos, this is likely the cause. It is recommended you turn this feature off by adding 'GraphIEC = 0' to your options.txt. (I also turn off the buzzer option).

## Function Lock Jumpers

VIC-II Kawari was built to be detected, flashed and re-configured from the C64 main CPU. To prevent a program from (intentionally or accidentally) 'bricking' your VIC-II Kawari, some functions can be locked from programmatic access.

See [REGISTERS.md](doc/REGISTERS.md) for a description of the lock jumpers.

By default, flash operations are DISABLED. This means you must physically remove the jumper on Pin 1 to allow the flash utility to work.  (It is recommended you put the jumper back after you've flashed the device.)

Also by default, persistence (extended register changes persisting between reboots) is ENABLED. Once you've set your preferred color scheme or other preferences with the config apps, you can remove the jumper on Pin 2 to prevent any program changing them without your knowledge/permission. Programs will still be able to change colors. But they won't be able to save them.

Access to extension registers (extended features) are ENABLED by default. If you want your VIC-II Kawari to function as a regular 6567/6569 and be undetectable to any program (including Kawari config apps) then removing the extension lock jumper on Pin 2 will do that. (NOTE: That includes being able to software switch the video standard. However, a hardware switch will still work.)

Without the lock jumpers, here are some ways a misbehaving program can make it look like your VIC-II Kawari has died:

1. erase the flash memory making the device un-bootable (must be restored via JTAG/SPI programmer)
2. change all colors to black and save them, making it look like a black screen fault (restored by shorting CFG jumper pad)
3. change the hires modes to a resolution incompatible with your monitor, again making it look like a black screen fault (restored by shorting CFG jumper pad)

## Forking VIC-II Kawari?

If you intend to fork VIC-II Kawari to add your own features, please read [FORKING.md](doc/FORKING.md)

