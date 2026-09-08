#!/usr/bin/env python3
import sys
import os
import math
import inkex

class ArrowHelper:
    # Marker definitions: (path_d, is_stroke, stroke_width)
    MARKERS = {
        'MathArrowEnd_v2': ('M 5,0 L -2,-3.5 L 0,0 L -2,3.5 Z', False, '1.0'),
        'MathArrowStart_v2': ('M -5,0 L 2,-3.5 L 0,0 L 2,3.5 Z', False, '1.0'),
        'MathDoubleEnd_v2': ('M 5,0 L -2,-3.5 L 0,0 L -2,3.5 Z M 0,0 L -7,-3.5 L -5,0 L -7,3.5 Z', False, '1.0'),
        'MathDoubleStart_v2': ('M -5,0 L 2,-3.5 L 0,0 L 2,3.5 Z M 0,0 L 7,-3.5 L 5,0 L 7,3.5 Z', False, '1.0'),
        'MathBarStart_v2': ('M 0,-3.5 L 0,3.5', True, '1.2'),
        'MathBarEnd_v2': ('M 0,-3.5 L 0,3.5', True, '1.2'),
        'MathHookStart_v2': ('M 0,0 C -1.5,0 -2.8,0.8 -2.8,2.2 C -2.8,3.6 -1.5,4.4 0.0,4.4', True, '1.0'),
        'MathHookEnd_v2': ('M 0,0 C 1.5,0 2.8,0.8 2.8,2.2 C 2.8,3.6 1.5,4.4 0.0,4.4', True, '1.0'),
    }

    @classmethod
    def ensure_markers(cls, svg):
        for mid, (d_path, is_stroke, sw) in cls.MARKERS.items():
            existing = svg.getElementById(mid)
            if existing is not None:
                existing.set('orient', 'auto')
                existing.set('refX', '0.0')
                existing.set('refY', '0.0')
                existing.style = {'overflow': 'visible'}
                for child in list(existing):
                    existing.remove(child)
                path_el = inkex.PathElement(d=d_path)
                if is_stroke:
                    path_el.style = {
                        'fill': 'none',
                        'stroke': 'context-stroke',
                        'stroke-width': sw,
                        'stroke-linecap': 'round',
                        'stroke-linejoin': 'round'
                    }
                else:
                    path_el.style = {
                        'fill': 'context-stroke',
                        'fill-rule': 'evenodd',
                        'stroke': 'none'
                    }
                existing.append(path_el)
            else:
                marker = inkex.Marker(id=mid, orient='auto', refX='0.0', refY='0.0')
                marker.style = {'overflow': 'visible'}
                path_el = inkex.PathElement(d=d_path)
                if is_stroke:
                    path_el.style = {
                        'fill': 'none',
                        'stroke': 'context-stroke',
                        'stroke-width': sw,
                        'stroke-linecap': 'round',
                        'stroke-linejoin': 'round'
                    }
                else:
                    path_el.style = {
                        'fill': 'context-stroke',
                        'fill-rule': 'evenodd',
                        'stroke': 'none'
                    }
                marker.append(path_el)
                svg.defs.append(marker)

    @classmethod
    def get_mid_helper(cls, svg, node_id):
        helpers = svg.xpath(f'//*[@data-parent-id="{node_id}" and @class="mid-arrow-helper"]')
        return helpers[0] if helpers else None

    @classmethod
    def remove_mid_helper(cls, svg, node_id):
        for h in svg.xpath(f'//*[@data-parent-id="{node_id}" and @class="mid-arrow-helper"]'):
            try:
                h.getparent().remove(h)
            except Exception:
                pass

    @classmethod
    def get_midpoint_and_tangent(cls, node):
        path = node.path.to_absolute()
        segments = []
        current_pt = [0.0, 0.0]
        
        for cmd in path:
            name = cmd.letter.upper()
            args = [float(a) for a in cmd.args]
            if name == 'M':
                current_pt = [args[-2], args[-1]]
            elif name == 'L':
                p1 = [args[-2], args[-1]]
                segments.append(('L', list(current_pt), p1))
                current_pt = p1
            elif name == 'C':
                p1 = [args[0], args[1]]
                p2 = [args[2], args[3]]
                p3 = [args[4], args[5]]
                segments.append(('C', list(current_pt), p1, p2, p3))
                current_pt = p3
            elif name in ['Q', 'S', 'A', 'T', 'Z', 'V', 'H']:
                p1 = [args[-2], args[-1]] if len(args) >= 2 else list(current_pt)
                segments.append(('L', list(current_pt), p1))
                current_pt = p1

        if not segments:
            bbox = node.bounding_box()
            if bbox:
                return bbox.center.x, bbox.center.y, 0.0
            return 0.0, 0.0, 0.0

        seg_samples = []
        total_len = 0.0
        for seg in segments:
            stype = seg[0]
            if stype == 'L':
                p0, p1 = seg[1], seg[2]
                slen = math.hypot(p1[0]-p0[0], p1[1]-p0[1])
                steps = max(2, int(slen / 1.0))
                pts = []
                for i in range(steps + 1):
                    t = i / float(steps)
                    pts.append((p0[0] + t*(p1[0]-p0[0]), p0[1] + t*(p1[1]-p0[1]), (p1[0]-p0[0], p1[1]-p0[1])))
                seg_samples.append((slen, pts))
                total_len += slen
            elif stype == 'C':
                p0, p1, p2, p3 = seg[1], seg[2], seg[3], seg[4]
                steps = 50
                pts = []
                cur_len = 0.0
                prev_pt = p0
                for i in range(steps + 1):
                    t = i / float(steps)
                    mt = 1.0 - t
                    x = mt**3*p0[0] + 3*mt**2*t*p1[0] + 3*mt*t**2*p2[0] + t**3*p3[0]
                    y = mt**3*p0[1] + 3*mt**2*t*p1[1] + 3*mt*t**2*p2[1] + t**3*p3[1]
                    dx = 3*mt**2*(p1[0]-p0[0]) + 6*mt*t*(p2[0]-p1[0]) + 3*t**2*(p3[0]-p2[0])
                    dy = 3*mt**2*(p1[1]-p0[1]) + 6*mt*t*(p2[1]-p1[1]) + 3*t**2*(p3[1]-p2[1])
                    if i > 0:
                        cur_len += math.hypot(x - prev_pt[0], y - prev_pt[1])
                    pts.append((x, y, (dx, dy)))
                    prev_pt = (x, y)
                seg_samples.append((cur_len, pts))
                total_len += cur_len

        if total_len == 0.0:
            return current_pt[0], current_pt[1], 0.0

        target_len = total_len / 2.0
        accum_len = 0.0
        for slen, pts in seg_samples:
            if accum_len + slen >= target_len or slen == 0:
                rem = target_len - accum_len
                ratio = max(0.0, min(1.0, rem / slen)) if slen > 0 else 0.0
                idx = int(ratio * (len(pts) - 1))
                mx, my, (dx, dy) = pts[idx]
                angle = math.degrees(math.atan2(dy, dx))
                return mx, my, angle
            accum_len += slen

        p = seg_samples[-1][1][-1]
        return p[0], p[1], math.degrees(math.atan2(p[2][1], p[2][0]))

    @classmethod
    def create_mid_arrow(cls, svg, node, reverse=False):
        node_id = node.get('id')
        if not node_id:
            node_id = svg.get_unique_id('path')
            node.set('id', node_id)
        cls.remove_mid_helper(svg, node_id)
        mx, my, angle = cls.get_midpoint_and_tangent(node)
        if reverse:
            angle = (angle + 180.0) % 360.0
            
        try:
            stroke_width = float(str(node.style.get('stroke-width', '1')).replace('px', '').replace(',', '.'))
        except ValueError:
            stroke_width = 1.0

        stroke_color = node.style.get('stroke', '#000000')
        if not stroke_color or stroke_color == 'none':
            stroke_color = '#000000'

        arrow = inkex.PathElement(d='M 3.5,0 L -3.5,-3.5 L -1.5,0 L -3.5,3.5 Z')
        arrow.style = {'fill': stroke_color, 'stroke': 'none'}
        arrow.set('class', 'mid-arrow-helper')
        arrow.set('data-parent-id', node_id)
        arrow.set('data-reverse', 'true' if reverse else 'false')
        
        local_tf = inkex.Transform(f'translate({mx},{my}) rotate({angle}) scale({stroke_width})')
        arrow.transform = node.transform @ local_tf
        
        parent = node.getparent()
        parent.insert(parent.index(node) + 1, arrow)

    @classmethod
    def get_current_state(cls, svg, node):
        node_id = node.get('id')
        if node_id:
            mid_helper = cls.get_mid_helper(svg, node_id)
            if mid_helper is not None:
                is_rev = mid_helper.get('data-reverse') == 'true'
                return 10 if is_rev else 9

        m_start = node.style.get('marker-start', 'none')
        m_end = node.style.get('marker-end', 'none')

        if m_start == 'none' and m_end == 'url(#MathArrowEnd_v2)':
            return 1
        if m_start == 'none' and m_end == 'url(#MathDoubleEnd_v2)':
            return 2
        if m_start == 'url(#MathArrowStart_v2)' and m_end == 'none':
            return 3
        if m_start == 'url(#MathDoubleStart_v2)' and m_end == 'none':
            return 4
        if m_start == 'url(#MathArrowStart_v2)' and m_end == 'url(#MathArrowEnd_v2)':
            return 5
        if m_start == 'url(#MathDoubleStart_v2)' and m_end == 'url(#MathDoubleEnd_v2)':
            return 6
        if m_start == 'url(#MathBarStart_v2)' and m_end == 'url(#MathArrowEnd_v2)':
            return 7
        if m_start == 'url(#MathHookStart_v2)' and m_end == 'url(#MathArrowEnd_v2)':
            return 8
        if m_end != 'none' and m_start == 'none':
            return 1
        if m_start != 'none' and m_end == 'none':
            return 3
        if m_start != 'none' and m_end != 'none':
            return 5
        return 0

    @classmethod
    def apply_state(cls, svg, node, state):
        node_id = node.get('id')
        if not node_id:
            node_id = svg.get_unique_id('path')
            node.set('id', node_id)

        cls.remove_mid_helper(svg, node_id)

        if state == 0:
            node.style['marker-start'] = 'none'
            node.style['marker-end'] = 'none'
        elif state == 1:
            node.style['marker-start'] = 'none'
            node.style['marker-end'] = 'url(#MathArrowEnd_v2)'
        elif state == 2:
            node.style['marker-start'] = 'none'
            node.style['marker-end'] = 'url(#MathDoubleEnd_v2)'
        elif state == 3:
            node.style['marker-start'] = 'url(#MathArrowStart_v2)'
            node.style['marker-end'] = 'none'
        elif state == 4:
            node.style['marker-start'] = 'url(#MathDoubleStart_v2)'
            node.style['marker-end'] = 'none'
        elif state == 5:
            node.style['marker-start'] = 'url(#MathArrowStart_v2)'
            node.style['marker-end'] = 'url(#MathArrowEnd_v2)'
        elif state == 6:
            node.style['marker-start'] = 'url(#MathDoubleStart_v2)'
            node.style['marker-end'] = 'url(#MathDoubleEnd_v2)'
        elif state == 7:
            node.style['marker-start'] = 'url(#MathBarStart_v2)'
            node.style['marker-end'] = 'url(#MathArrowEnd_v2)'
        elif state == 8:
            node.style['marker-start'] = 'url(#MathHookStart_v2)'
            node.style['marker-end'] = 'url(#MathArrowEnd_v2)'
        elif state == 9:
            node.style['marker-start'] = 'none'
            node.style['marker-end'] = 'none'
            cls.create_mid_arrow(svg, node, reverse=False)
        elif state == 10:
            node.style['marker-start'] = 'none'
            node.style['marker-end'] = 'none'
            cls.create_mid_arrow(svg, node, reverse=True)

    @classmethod
    def cycle(cls, svg, node, direction=1):
        TOTAL_STATES = 11
        cur_state = cls.get_current_state(svg, node)
        new_state = (cur_state + direction) % TOTAL_STATES
        cls.apply_state(svg, node, new_state)

    @classmethod
    def reverse(cls, svg, node):
        cur_state = cls.get_current_state(svg, node)
        flip_map = {
            0: 0,
            1: 3,
            2: 4,
            3: 1,
            4: 2,
            5: 5,
            6: 6,
            7: 1,
            8: 1,
            9: 10,
            10: 9
        }
        new_state = flip_map.get(cur_state, 0)
        if cur_state == 0 or cur_state in [5, 6]:
            try:
                node.path = node.path.reverse()
            except Exception:
                pass
        else:
            cls.apply_state(svg, node, new_state)


class CycleArrow(inkex.EffectExtension):
    def effect(self):
        ArrowHelper.ensure_markers(self.svg)
        for node in self.svg.selection.values():
            if isinstance(node, (inkex.TextElement, inkex.Tspan)):
                continue
            ArrowHelper.cycle(self.svg, node, direction=1)

if __name__ == '__main__':
    CycleArrow().run()
