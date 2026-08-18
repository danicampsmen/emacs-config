#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

import inkex
from castel_stroke import cycle_stroke_style

class CycleStrokePrev(inkex.EffectExtension):
    def effect(self):
        cycle_stroke_style(self.svg, direction=-1)

if __name__ == '__main__':
    CycleStrokePrev().run()
