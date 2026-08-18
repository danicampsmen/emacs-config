#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

import inkex
from castel_color import cycle_color_stroke

class CycleColorPrev(inkex.EffectExtension):
    def effect(self):
        cycle_color_stroke(self.svg, direction=-1)

if __name__ == '__main__':
    CycleColorPrev().run()
