SELECT
    analisis,
    MAX(total_productos) AS total_productos,

    SUM(pertenece_80) AS productos_para_80_pct,

    ROUND(
        100.0 * SUM(pertenece_80) / MAX(total_productos), 2
    ) AS porcentaje_del_catalogo,

    ROUND(MAX(total_contribucion), 2) AS total_economico,

    ROUND(
        SUM(CASE WHEN pertenece_80 = 1
            THEN contribucion ELSE 0 END), 2
    ) AS importe_grupo_pareto,

    CASE
        WHEN MAX(total_contribucion) > 0
        THEN ROUND(
            100.0 * SUM(
                CASE WHEN pertenece_80 = 1
                    THEN contribucion ELSE 0 END
            ) / MAX(total_contribucion), 2
        )
    END AS porcentaje_economico_alcanzado

FROM pareto_superstore
GROUP BY analisis
ORDER BY analisis;
