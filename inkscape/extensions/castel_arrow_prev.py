#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

import inkex
from castel_arrow import ArrowHelper

class CycleArrowPrev(inkex.EffectExtension):
    def effect(self):
        ArrowHelper.ensure_markers(self.svg)
        for node in self.svg.selection.values():
            if isinstance(node, (inkex.TextElement, inkex.Tspan)):
                continue
            ArrowHelper.cycle(self.svg, node, direction=-1)

if __name__ == '__main__':
    CycleArrowPrev().run()
