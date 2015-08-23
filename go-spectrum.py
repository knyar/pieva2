#!/usr/bin/env python
import yappi
import argparse
import pyximport; pyximport.install()

from bibliopixel import LEDMatrix
from bibliopixel.led import *

from recorder import AlsaRecorder, PyAudioRecorder, EQ, BassPulse
from pbdriver import DriverPieva, DriverPievaX4, DriverPievaX4Rev

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Spectrum analyzer')
    parser.add_argument('--profiling', type=bool, default=False)
    parser.add_argument('--recorder', choices=['pyaudio', 'alsa'], default='alsa')
    parser.add_argument('--display', choices=['full', 'x4', 'x4rev'], default='x4')
    parser.add_argument('--anim', choices=['eq', 'bass', 'test'], default='eq')
    parser.add_argument('--fps', default=20, type=int)
    parser.add_argument('--min_freq', default=50)    # 50 Hz
    parser.add_argument('--max_freq', default=15000) # 15000 Hz
    parser.add_argument('--sensitivity', default=3, type=float)  # lower is more sensitive
    args = parser.parse_args()

    if args.profiling:
        yappi.start()

    if args.display == 'full':
        w = 140
        h = 140
        driver = DriverPieva(width=w, height=h)
    else:
        w = 70
        h = 70
        if args.display == 'x4':
            driver = DriverPievaX4(width=w, height=h)
        else:
            driver = DriverPievaX4Rev(width=w, height=h)

    led = LEDMatrix(driver, width=w, height=h, serpentine=False)
    led.setMasterBrightness(255)

    if args.recorder == 'alsa':
        recorder = AlsaRecorder()
    else:
        recorder = PyAudioRecorder()

    if args.anim == 'eq':
        anim = EQ(recorder, led, args.min_freq, args.max_freq, args.sensitivity)
    elif args.anim == 'bass':
        anim = BassPulse(recorder, led, args.min_freq, args.max_freq, args.sensitivity)
    else:
        from bibliopixel.animation import MatrixCalibrationTest, MatrixChannelTest
        anim = MatrixCalibrationTest(led)

    print driver, led, anim
    try:
        anim.run(fps=args.fps)
    except KeyboardInterrupt:
        pass

    anim.endRecord()
    led.all_off()
    led.update()
    if args.profiling:
        yappi.get_func_stats().print_all()
