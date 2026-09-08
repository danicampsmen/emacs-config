#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

import inkex
from castel_width import cycle_width_style

class CycleWidthPrev(inkex.EffectExtension):
    def effect(self):
        cycle_width_style(self.svg, direction=-1)

if __name__ == '__main__':
    CycleWidthPrev().run()
