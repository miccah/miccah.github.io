---
layout: kb
title:  "Kirchhoff's Laws"
category: Electrical Engineering
---
<script>MathJax = { tex: { inlineMath: {'[+]': [['$', '$']]} } };</script>
<script defer src="https://cdn.jsdelivr.net/npm/mathjax@4/tex-chtml.js"></script>

## Kirchhoff's Current Law
For any node in an electrical circuit, the sum of currents flowing
into that node is equal to the sum of currents flowing out of the
node.

$$ \sum_{k=1}^{n} I_k = 0 $$

## Kirchhoff's Voltage Law
The directed sum of the potential differences (voltages) around any
closed loop is zero.

$$ \sum_{k=1}^{n} V_k = 0 $$

## Usage
We can use these two laws to find the current and voltage at any
point in a linear circuit. To do so, we create a system of linear
equations to solve.

<div style="text-align: center"><img src="/assets/kb/kirchhoff_example.svg" style="width: 480px"/></div>

From the above example, we get these three equations:

$$ i_1 - i_2 - i_3 = 0 $$

$$ - i_1R_1 - i_2R_2 + \mathcal{E}_1 = 0 $$

$$ - \mathcal{E}_1 + i_2R_2 - i_3R_3 - \mathcal{E}_2 = 0 $$

which can be solved using linear algebra:

<p>
\[
\begin{bmatrix}
1 & -1 & -1 \\\
-R_1 & -R_2 & 0 \\\
0 & R_2 & -R_3
\end{bmatrix}
\begin{bmatrix}
i_1 \\\
i_2 \\\
i_3
\end{bmatrix}
=
\begin{bmatrix}
0 \\\
-\mathcal{E}_1 \\\
\mathcal{E}_1 + \mathcal{E}_2
\end{bmatrix}
\]
</p>
