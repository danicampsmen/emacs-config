#!/usr/bin/env python3
import inkex

class GeneratePoint(inkex.EffectExtension):
    def effect(self):
        for node in self.svg.selection.values():
            # Obtener el centro del objeto seleccionado
            bbox = node.bounding_box()
            if bbox:
                cx = bbox.center.x
                cy = bbox.center.y
                
                # Crear un circulo nuevo perfecto en esas coordenadas
                circle = inkex.Circle(cx=str(cx), cy=str(cy), r="2")
                circle.style = {'fill': '#000000', 'stroke': 'none'}
                
                # Insertar en el lienzo y borrar la basura original
                node.getparent().append(circle)
                node.delete()

if __name__ == '__main__':
    GeneratePoint().run()
