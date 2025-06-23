-- Question 1 :
EXPLAIN ANALYZE
SELECT b.start_year, COUNT(*) AS nb_films, AVG(r.average_rating) AS note_moyenne
FROM title_basics b
JOIN title_ratings r ON b.tconst = r.tconst
WHERE b.title_type = 'movie'
  AND b.start_year BETWEEN 1990 AND 2000
GROUP BY b.start_year
ORDER BY note_moyenne DESC;

-- Question 2 :
-- 1. Les étapes du plan sont généralement :
--    - Scan (Seq Scan, Index Scan ou Bitmap Scan sur title_basics et/ou title_ratings)
--    - Hash Join (pour la jointure sur tconst)
--    - Partial Aggregate puis Finalize Aggregate (agrégation en deux phases)
--    - Sort (tri final sur note moyenne)
-- 2. L'agrégation est réalisée en deux phases (Partial puis Finalize) pour permettre le parallélisme : chaque worker calcule une agrégation partielle, puis les résultats sont fusionnés.
-- 3. Les index existants sur start_year, title_type ou average_rating peuvent être utilisés pour filtrer plus rapidement, mais la jointure sur tconst nécessite un scan ou un hash si l'index n'est pas présent.
-- 4. Le tri final peut être coûteux si beaucoup de lignes sont agrégées, car il faut trier en mémoire ou sur disque selon la taille des résultats.

-- Question 3 :
CREATE INDEX idx_title_basics_tconst ON title_basics(tconst);
CREATE INDEX idx_title_ratings_tconst ON title_ratings(tconst);

-- Question 4 :
EXPLAIN ANALYZE
SELECT b.start_year, COUNT(*) AS nb_films, AVG(r.average_rating) AS note_moyenne
FROM title_basics b
JOIN title_ratings r ON b.tconst = r.tconst
WHERE b.title_type = 'movie'
  AND b.start_year BETWEEN 1990 AND 2000
GROUP BY b.start_year
ORDER BY note_moyenne DESC;

-- Question 5 :
-- 1. Pas toujours : si la table est très grande et que la jointure concerne beaucoup de lignes, PostgreSQL préfère souvent un Hash Join.
-- 2. Parce que la jointure porte sur une grande partie des tables, donc le coût d'un Hash Join reste compétitif par rapport à l'utilisation des index.
-- 3. Si la jointure porte sur un petit sous-ensemble de lignes (requête très sélective), ou si la table est très grande mais la jointure ne concerne que peu de lignes (lookup ponctuel).
