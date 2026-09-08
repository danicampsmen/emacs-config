#!/usr/bin/env python3
import math
import inkex

# Librería completa de patrones de trazo (17 patrones técnicos y analíticos)
DASH_PATTERNS = [
    ('Sólido continuo', 'none'),
    ('Guiones estándar medios (4, 4)', '4, 4'),
    ('Guiones cortos (2, 2)', '2, 2'),
    ('Punteado denso / Tramado (1, 1)', '1, 1'),
    ('Punteado fino estándar (1, 3)', '1, 3'),
    ('Punteado espaciado (1, 5)', '1, 5'),
    ('Micro-puntos sutiles (0.5, 2)', '0.5, 2'),
    ('Guiones densos (6, 2)', '6, 2'),
    ('Guiones largos estándar (8, 4)', '8, 4'),
    ('Guiones extra largos (12, 4)', '12, 4'),
    ('Guiones ultra largos (16, 6)', '16, 6'),
    ('Raya-Punto eje simetría (6, 3, 1, 3)', '6, 3, 1, 3'),
    ('Raya larga-Punto mayor (10, 3, 2, 3)', '10, 3, 2, 3'),
    ('Raya-Doble punto plano de corte (8, 3, 1, 3, 1, 3)', '8, 3, 1, 3, 1, 3'),
    ('Raya-Triple punto envolvente (12, 3, 1, 3, 1, 3, 1, 3)', '12, 3, 1, 3, 1, 3, 1, 3'),
    ('Raya larga - Raya corta (12, 3, 4, 3)', '12, 3, 4, 3'),
    ('Ritmo / Onda periódica (4, 2, 1, 2, 1, 2)', '4, 2, 1, 2, 1, 2'),
]

def get_node_path_length(node):
    try:
        path = node.path.to_absolute()
    except Exception:
        return 100.0

    total_len = 0.0
    current_pt = [0.0, 0.0]
    
    for cmd in path:
        name = cmd.letter.upper()
        args = [float(a) for a in cmd.args]
        if name == 'M':
            current_pt = [args[-2], args[-1]]
        elif name == 'L':
            p1 = [args[-2], args[-1]]
            total_len += math.hypot(p1[0] - current_pt[0], p1[1] - current_pt[1])
            current_pt = p1
        elif name == 'C':
            p0 = current_pt
            p1 = [args[0], args[1]]
            p2 = [args[2], args[3]]
            p3 = [args[4], args[5]]
            steps = 30
            prev_pt = p0
            for i in range(1, steps + 1):
                t = i / float(steps)
                mt = 1.0 - t
                x = mt**3*p0[0] + 3*mt**2*t*p1[0] + 3*mt*t**2*p2[0] + t**3*p3[0]
                y = mt**3*p0[1] + 3*mt**2*t*p1[1] + 3*mt*t**2*p2[1] + t**3*p3[1]
                total_len += math.hypot(x - prev_pt[0], y - prev_pt[1])
                prev_pt = (x, y)
            current_pt = p3
        elif name in ['Q', 'S', 'A', 'T', 'Z', 'V', 'H']:
            p1 = [args[-2], args[-1]] if len(args) >= 2 else list(current_pt)
            total_len += math.hypot(p1[0] - current_pt[0], p1[1] - current_pt[1])
            current_pt = p1

    return total_len if total_len > 0 else 100.0

def is_path_closed(node):
    try:
        for cmd in node.path:
            if cmd.letter.upper() == 'Z':
                return True
    except Exception:
        pass
    return False

def compute_equitable_dasharray(base_pattern_str, path_length, stroke_width=1.0, is_closed=False):
    """
    Ajusta matemáticamente el patrón de guiones para que se distribuya de forma 100%
    equitativa y simétrica en la longitud total de la curva, sin cortes asimétricos.
    """
    if base_pattern_str == 'none' or path_length <= 0:
        return 'none'

    raw_vals = [float(x.strip()) for x in base_pattern_str.replace(' ', ',').split(',') if x.strip()]
    if not raw_vals:
        return 'none'

    sw = max(0.5, stroke_width)
    scaled_base = [v * sw for v in raw_vals]

    # Para patrones binarios (guión + espacio) en trazos abiertos:
    # Ajustar para que inicie y termine con un guión completo y simétrico
    if len(scaled_base) == 2 and not is_closed:
        d_base, g_base = scaled_base
        r = g_base / d_base if d_base > 0 else 1.0
        target_period = d_base + g_base
        n_dashes = max(1, round((path_length + g_base) / target_period))
        d_fitted = path_length / (n_dashes + (n_dashes - 1) * r)
        g_fitted = d_fitted * r
        fitted_vals = [d_fitted, g_fitted]
    else:
        # Para patrones complejos: escalar el periodo para que quepa un número entero de ciclos
        period = sum(scaled_base)
        if period <= 0:
            return 'none'
        n_cycles = max(1, round(path_length / period))
        scale = path_length / (n_cycles * period)
        fitted_vals = [v * scale for v in scaled_base]

    return ', '.join(f'{v:.2f}'.rstrip('0').rstrip('.') for v in fitted_vals)

def cycle_stroke_style(svg, direction=1):
    for node in svg.selection.values():
        if isinstance(node, (inkex.TextElement, inkex.Tspan)):
            continue

        # Obtener el índice actual desde el atributo guardado o por coincidencia
        saved_idx_str = node.get('data-dash-idx')
        cur_dash = str(node.style.get('stroke-dasharray', 'none')).strip().lower()

        if saved_idx_str is not None:
            try:
                found_idx = int(saved_idx_str)
            except ValueError:
                found_idx = -1
        else:
            found_idx = -1
            if cur_dash == 'none':
                found_idx = 0

        if found_idx == -1:
            new_idx = 1 if direction > 0 else len(DASH_PATTERNS) - 1
        else:
            new_idx = (found_idx + direction) % len(DASH_PATTERNS)

        name, base_pattern = DASH_PATTERNS[new_idx]
        node.set('data-dash-idx', str(new_idx))

        if base_pattern == 'none':
            node.style['stroke-dasharray'] = 'none'
        else:
            path_len = get_node_path_length(node)
            closed = is_path_closed(node)
            try:
                sw_val = float(str(node.style.get('stroke-width', '1')).replace('px', '').replace(',', '.'))
            except ValueError:
                sw_val = 1.0

            eq_dash = compute_equitable_dasharray(base_pattern, path_len, stroke_width=sw_val, is_closed=closed)
            node.style['stroke-dasharray'] = eq_dash

class CycleStroke(inkex.EffectExtension):
    def effect(self):
        cycle_stroke_style(self.svg, direction=1)

if __name__ == '__main__':
    CycleStroke().run()
