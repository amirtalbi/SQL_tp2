-- Question 1 :
EXPLAIN ANALYZE
SELECT b.primary_title, r.average_rating
FROM title_basics b
JOIN title_ratings r ON b.tconst = r.tconst
WHERE b.tconst = 'tt0111161';

-- Question 2 :
-- 1. L'algorithme de jointure utilisé est généralement un Nested Loop Join ou un Index Join, car la requête ne concerne qu'une seule ligne.
-- 2. Les index sur tconst sont utilisés pour accéder directement à la ligne recherchée dans chaque table, ce qui évite tout scan inutile.
-- 3. Le temps d'exécution est bien plus faible que pour les requêtes précédentes, car seule une ligne est lue et jointe.
-- 4. Cette requête est très rapide car elle exploite pleinement les index sur tconst, ce qui permet un accès direct (lookup) sans parcourir la table entière ni effectuer de jointure coûteuse.
