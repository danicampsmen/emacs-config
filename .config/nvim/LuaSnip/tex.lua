-- ~/.config/nvim/LuaSnip/tex.lua

-- =====================================================================
-- 1. PREPARACIÓN Y ABREVIATURAS (Filosofía ejmastnak)
-- =====================================================================
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local i = ls.insert_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta

-- Función de ejmastnak para replicar tu selección visual ('r' de Tempel)
local get_visual = function(args, parent)
  if (#parent.snippet.env.LS_SELECT_RAW > 0) then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else
    return sn(nil, i(1))
  end
end

-- Reemplazo de `laas-mathp` usando VimTeX
local tex_utils = {}
tex_utils.in_mathzone = function()
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end

-- =====================================================================
-- 2. TUS SNIPPETS (Traducción de my-latex-snippets.el a LuaSnip)
-- =====================================================================
return {
  -- ==========================================
  -- MACROESTRUCTURAS Y ENTORNOS (Se expanden pulsando TAB)
  -- ==========================================

  -- Teorema (Traducción de tu 'thm' de Tempel)
  s({trig="thm", dscr="Entorno Theorem"},
    fmta(
      [[
        \begin{theorem}[<>]
            <>
        \end{theorem}
      ]],
      { i(1), d(2, get_visual) }
    )
  ),

  -- Figura académica (Traducción de tu 'fig' de Tempel)
  s({trig="fig", dscr="Entorno figure académico"},
    fmta(
      [[
        \begin{figure}[<>]
            \centering
            \includegraphics[width=<>\linewidth]{<>}
            \caption{<>}
            \label{fig:<>}
        \end{figure}
        <>
      ]],
      { i(1, "htpb"), i(2, "0.8"), i(3), i(4), i(5), i(0) }
    )
  ),

}, {
  -- ==========================================
  -- AUTOSNIPPETS MATEMÁTICOS (Reemplazo de LAAS)
  -- ==========================================

  -- Modo matemático inline (Traducción de tu 'im' de Emacs)
  s({trig="im", snippetType="autosnippet"},
    fmta("$<>$", { d(1, get_visual) })
  ),

  -- Display math (Traducción de tu 'dm' de Emacs)
  s({trig="dm", snippetType="autosnippet"},
    fmta(
      [[
        \[
            <>
        \]
      ]],
      { d(1, get_visual) }
    )
  ),

  -- Paréntesis Dinámicos (Traducción de tu 'dp' de Tempel)
  s({trig="dp", snippetType="autosnippet"},
    fmta("\\left( <> \\right)", { d(1, get_visual) })
  ),

  -- Fracción (Sensible al contexto matemático)
  s({trig="fr", snippetType="autosnippet", condition=tex_utils.in_mathzone},
    fmta("\\frac{<>}{<>}", { d(1, get_visual), i(2) })
  ),

  -- Derivada Parcial
  s({trig="part", snippetType="autosnippet", condition=tex_utils.in_mathzone},
    fmta("\\frac{\\partial <>}{\\partial <>}", { i(1, "f"), i(2, "x") })
  ),

  -- Fuentes matemáticas (Traducción de tu 'mbb')
  s({trig="mbb", snippetType="autosnippet", condition=tex_utils.in_mathzone},
    fmta("\\mathbb{<>}", { d(1, get_visual) })
  ),
}