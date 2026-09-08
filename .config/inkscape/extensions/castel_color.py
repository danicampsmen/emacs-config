#!/usr/bin/env python3
import inkex

# Paleta espectral amplia y equilibrada optimizada para figuras matemáticas, física y diagramas
COLORS = [
    '#000000',  # 0. Negro (Ejes, trazos base, texto)
    '#546e7a',  # 1. Gris Pizarra / Azulado (Guías, cuadrícula, ejes secundarios)
    '#e53935',  # 2. Rojo Carmín (Destacados, vectores principales, fuerzas)
    '#ff5722',  # 3. Rojo Coral / Deep Orange (Atención, calor, aceleraciones)
    '#fb8c00',  # 4. Naranja (Ángulos, parámetros, advertencias)
    '#fdd835',  # 5. Amarillo Sol (Resaltados, energía, focos)
    '#7cb342',  # 6. Lima / Verde Claro (Derivadas, tangentes, valores intermedios)
    '#2e7d32',  # 7. Verde Bosque (Resultados, conjuntos, soluciones)
    '#00897b',  # 8. Verde Azulado / Teal (Campos magnéticos, flujos, densidades)
    '#00acc1',  # 9. Cian / Turquesa (Gradientes, áreas, curvas de nivel)
    '#1e88e5',  # 10. Azul Real (Funciones principales f(x), subespacios)
    '#0d47a1',  # 11. Azul Marino / Navy Blue (Estructuras densas, campos vectoriales)
    '#3949ab',  # 12. Índigo / Azul Profundo (Bases ortonormales, variedades)
    '#8e24aa',  # 13. Morado / Violeta (Funciones secundarias g(x), tensores)
    '#d500f9',  # 14. Magenta / Vívido (Puntos singulares, órbitas periódicas, resonancias)
    '#d81b60',  # 15. Rosa / Fucsia (Complementos, asíntotas, homotopías)
    '#8d6e63',  # 16. Marrón Cálido (Soportes físicos, masas, terreno)
    '#757575',  # 17. Gris Neutro (Líneas auxiliares, proyecciones)
]

def cycle_color_stroke(svg, direction=1):
    for node in svg.selection.values():
        if isinstance(node, (inkex.TextElement, inkex.Tspan)):
            continue

        current = str(node.style.get('stroke', '#000000')).strip().lower()
        if current in ['black', 'none', '']:
            current = '#000000'

        try:
            idx = COLORS.index(current)
        except ValueError:
            idx = 0

        new_color = COLORS[(idx + direction) % len(COLORS)]
        node.style['stroke'] = new_color

        # Sincronizar flechas intermedias (mid-arrow) vinculadas al objeto
        node_id = node.get('id')
        if node_id:
            for helper in svg.xpath(f'//*[@data-parent-id="{node_id}" and @class="mid-arrow-helper"]'):
                helper.style['fill'] = new_color

class CycleColor(inkex.EffectExtension):
    def effect(self):
        cycle_color_stroke(self.svg, direction=1)

if __name__ == '__main__':
    CycleColor().run()
