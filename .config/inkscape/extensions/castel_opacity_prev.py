#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

import inkex
from castel_opacity import cycle_opacity_style

class CycleOpacityPrev(inkex.EffectExtension):
    def effect(self):
        cycle_opacity_style(self.svg, direction=-1)

if __name__ == '__main__':
    CycleOpacityPrev().run()
