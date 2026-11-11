SELECT
    MAX(total_productos) AS total_productos,
    SUM(pertenece_80) AS productos_para_80_pct_ganancias,
    ROUND(
        100.0 * SUM(pertenece_80) / MAX(total_productos), 2
    ) AS porcentaje_del_catalogo,
    ROUND(
        SUM(CASE WHEN pertenece_80 = 1
            THEN contribucion ELSE 0 END), 2
    ) AS ganancia_acumulada
FROM pareto_superstore
WHERE analisis = 'GANANCIAS';
