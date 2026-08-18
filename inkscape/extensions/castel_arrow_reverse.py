#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.dirname(__file__))

import inkex
from castel_arrow import ArrowHelper

class ReverseArrow(inkex.EffectExtension):
    def effect(self):
        ArrowHelper.ensure_markers(self.svg)
        for node in self.svg.selection.values():
            if isinstance(node, (inkex.TextElement, inkex.Tspan)):
                continue
            ArrowHelper.reverse(self.svg, node)

if __name__ == '__main__':
    ReverseArrow().run()
